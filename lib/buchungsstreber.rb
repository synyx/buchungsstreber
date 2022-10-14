#!/usr/bin/ruby

require "yaml"
require "date"
require "fileutils"

require_relative 'buchungsstreber/version'
require_relative 'buchungsstreber/validator'
require_relative 'buchungsstreber/parser'
require_relative 'buchungsstreber/parser/buch_timesheet'
require_relative 'buchungsstreber/parser/yaml_timesheet'
require_relative 'buchungsstreber/aggregator'
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
      @timesheet_parser = TimesheetParser.new(@timesheet_file, @config[:issues], @config[:templates], @config[:minimum_time])
      @redmines = Redmines.new(@config[:redmines])

      @config[:generators].each_key do |gc|
        require_relative "buchungsstreber/generator/#{gc}"
      rescue LoadError
        $stderr.puts "Ignoring unknown generator #{gc}"
      end
      @generator = Generator.new(@config[:generators])
      @config[:generators].each_key do |gc|
        @generator.load!(gc)
      end

      require_relative "buchungsstreber/resolver/templates"
      require_relative "buchungsstreber/resolver/redmines"
      @config[:resolvers].each_key do |gc|
        require_relative "buchungsstreber/resolver/#{gc}"
      rescue LoadError
        $stderr.puts "Ignoring unknown resolver #{gc}"
      end
      @resolver = Resolver.new(@config)
      @config[:resolvers].each_key do |gc|
        @resolver.load!(gc)
      end
    end

    def entries(date = nil)
      entries = @timesheet_parser.parse.select { |x| date.nil? || date == x[:date] }

      result = {
        daily_hours: Hash.new(0),
        work_hours: Hash.new(@config[:hours]),
        valid: true,
        entries: [],
      }

      entries.each do |entry|
        errors = []
        redmine = @redmines.get(entry[:redmine])
        valid, err = fake_stderr do
          Validator.validate(entry, redmine)
        end
        errors << err unless valid
        result[:valid] &= valid
        result[:daily_hours][entry[:date]] += entry[:time]
        result[:work_hours][entry[:date]] = entry[:work_hours] if entry[:work_hours]

        title =
          begin
            redmine.get_issue(entry[:issue])
          rescue StandardError => e
            valid = false
            errors << e.message
            nil
          end
        redmine =
          if (entry[:redmine] || '').empty?
            nil
          else
            entry[:redmine]
          end

        result[:entries] << {
            date: entry[:date],
            time: entry[:time],
            activity: entry[:activity],
            redmine: redmine,
            issue: entry[:issue],
            title: title,
            text: entry[:text],
            valid: valid,
            errors: errors
        }
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
