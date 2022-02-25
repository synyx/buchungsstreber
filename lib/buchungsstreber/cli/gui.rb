require 'concurrent-ruby'
require 'glimmer-dsl-libui'

require_relative '../../buchungsstreber/watcher'

module Buchungsstreber
  module GUI
    class App
      include Glimmer

      def initialize(buchungsstreber, startdate = nil, options = {})
        @buchungsstreber = buchungsstreber
        @date = startdate
        @options = options
        @data = Concurrent::Array.new
        @day = ""
      end

      def start
        refresh_data

        @window = window('Buchungsstreber', 800, 400) {
          margined true
          vertical_box {
            label("Buchungsstreber") {
              stretchy false
              text @day
            }
            table {
              text_column
              text_column
              text_column
              text_column
              text_column
              text_column

              cell_rows @data
            }
            horizontal_box {
              stretchy false
              button(_('Buchen')) {
                stretchy true
                on_clicked do
                  buchen
                end
              }
              button(_('Generate')) {
                stretchy true
                on_clicked do
                  generate
                  refresh_data
                end
              }
            }
          }
        }

        Thread.start do
          Watcher.watch(@buchungsstreber.timesheet_file) do |_|
            refresh_data
          end
        end

        @window.show
      rescue Interrupt
        exit
      end

      private

      def refresh_data
        stats = @buchungsstreber.entries(@date)

        hours = stats[:entries].map { |x| x[:time] }.sum
        @day.replace "%s %sh / %sh\n" % [@date, hours, stats[:work_hours][@date]]

        entries = Aggregator.aggregate(stats[:entries])
        data = entries.map do |e|
          err = e[:errors].map { |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')
          [
            '',
            e[:date],
            e[:time],
            e[:redmine],
            (err || e[:title])[0..50],
            e[:text],
          ]
        end
        @data.replace data
      end

      def generate
        entries = @buchungsstreber.generate(@date)
        entries.each do |e|
          @buchungsstreber.resolve(e)
          e[:redmine] = nil if @buchungsstreber.redmines.default?(e[:redmine])
        end

        parser = @buchungsstreber.timesheet_parser
        parser.add(entries)
      end

      def buchen(date = nil)
        redmines = @buchungsstreber.redmines
        entries = @entries[:entries].select { |e| date.nil? || date == e[:date] }
        entries = Aggregator.aggregate(entries)

        entries.each_with_index do |entry, i|
          redmine = redmines.get(entry[:redmine])
          status = Validator.status!(entry, redmine)

          if status.grep(/(time|activity)_different/).any?
            success = false
            entry[:errors] << _('-> DIFF') + " #{$1}"
          elsif status.include?(:existing)
            success = true
          else
            success = redmine.add_time entry
          end
          @data[i][0] = success ? _('o') : _('x')
        end
      end
    end
  end
end
