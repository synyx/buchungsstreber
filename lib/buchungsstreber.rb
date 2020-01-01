#!/usr/bin/ruby

require "yaml"
require "date"
require "fileutils"

require_relative 'buchungsstreber/aggregator'
require_relative 'buchungsstreber/version'
require_relative 'buchungsstreber/validator'
require_relative 'buchungsstreber/parser'
require_relative 'buchungsstreber/parser/buch_timesheet'
require_relative 'buchungsstreber/parser/yaml_timesheet'
require_relative 'buchungsstreber/generator'
require_relative 'buchungsstreber/resolver'
require_relative 'buchungsstreber/redmine_api'
require_relative 'buchungsstreber/utils'
require_relative 'buchungsstreber/redmines'
require_relative 'buchungsstreber/config'

module Buchungsstreber

  class Context
    attr_reader :redmines, :timesheet_parser, :timesheet_file, :config

    def initialize(file = nil, config_file = nil)
      @config = Config.load(config_file)

      @timesheet_file = file || File.expand_path(@config[:timesheet_file])
      @timesheet_parser = TimesheetParser.new(@timesheet_file, @config[:templates])
      @redmines = Redmines.new(@config[:redmines])

      @config[:generators].keys.each do |gc|
        require_relative "buchungsstreber/generator/#{gc}"
      end
      @generator = Generator.new(@config[:generators])

      require_relative "buchungsstreber/resolver/templates"
      require_relative "buchungsstreber/resolver/redmines"
      @config[:resolvers].keys.each do |gc|
        require_relative "buchungsstreber/resolver/#{gc}"
      end
      @resolver = Resolver.new(@config)
    end

    def entries
      entries = @timesheet_parser.parse

      result = {
        daily_hours: Hash.new(0),
        work_hours: @config[:hours],
        valid: true,
        entries: [],
      }

      validator = Validator.new
      entries.each do |entry|
        errors = []
        redmine = @redmines.get(entry[:redmine])
        valid, err = fake_stderr do
          validator.validate(entry, redmine)
        end
        errors << err unless valid
        result[:valid] &= valid
        result[:daily_hours][entry[:date]] += entry[:time]

        title =
          begin
            redmine.get_issue(entry[:issue])
          rescue StandardError => e
            valid = false
            errors << e.message
            nil
          end

        result[:entries] << {date: entry[:date], time: entry[:time], title: title, text: entry[:text], valid: valid, errors: errors}
      end

      result
    end

    def generate(date)
      @generator.generate(date)
    end

    def resolve(entry)
      @resolver.resolve(entry)
    end

    private

    def fake_stderr
      original_stderr = $stderr
      $stderr = StringIO.new
      res = yield
      [res, $stderr.string]
    ensure
      $stderr = original_stderr
    end
  end
end
