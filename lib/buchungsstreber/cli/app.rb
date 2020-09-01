require 'thor'
require 'tempfile'
require 'i18n'
require_relative '../i18n/config'

include I18n::Gettext::Helpers
I18n::Backend::Simple.include(I18n::Backend::Gettext)
I18n.config.enforce_available_locales = false

require 'buchungsstreber'

module Buchungsstreber
  module CLI
    class App < Thor
      class_option :debug, :type => :boolean
      class_option :long, :type => :boolean
      class_option :file, type: :string

      desc '', _('Buchen')
      def execute
        title = "BUCHUNGSSTREBER v#{VERSION}"
        puts style(title, :bold)
        puts '~' * title.length
        puts ''

        unless Config.find_config
          invoke :init
          invoke :config if is_automated? || yes?(_('Konfiguration editieren?'))
        end

        entries = Buchungsstreber::Context.new(options[:file]).entries
        aggregated = Aggregator.aggregate(entries[:entries])
        tbl = aggregated.map do |e|
          status_color = {true => :blue, false => :red}[e[:valid]]
          err = e[:errors].map{ |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')
          [
            e[:date].strftime("%a:"),
            style("%sh" % e[:time], :bold),
            '@',
            style((err || '') + (e[:title] || ''), status_color, 50),
            style(e[:text], 30)
          ]
        end
        print_table(tbl, indent: 2)

        return unless entries[:valid]

        min_date, max_date = entries[:daily_hours].keys.minmax
        puts style(_('Zu buchende Stunden (%<min_date>s bis %<max_date>s):') % {min_date: min_date, max_date: max_date}, :bold)
        tbl = entries[:daily_hours].map do |date, hours|

          color = Utils.classify_workhours(hours, entries[:work_hours][date])
          ["#{date.strftime('%a')}:", style("#{hours}h", color)]
        end
        print_table(tbl, indent: 2)

        if is_automated? || yes?(_('Buchungen in Redmine uebernehmen? (y/N)'))
          invoke :buchen, [], entries: aggregated
          invoke :archivieren, [], entries: entries
        end
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      default_task :execute

      desc 'show date', _('Buchungen anzeigen')
      def show(date)
        entries = Buchungsstreber::Context.new(options[:file]).entries(Date.parse(date))
        aggregated = Aggregator.aggregate(entries[:entries])
        tbl = aggregated.map do |e|
          status_color = {true => :blue, false => :red}[e[:valid]]
          err = e[:errors].map{ |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')
          [
              e[:date].strftime("%a:"),
              style("%sh" % e[:time], :bold),
              '@',
              style((err || '') + (e[:title] || ''), status_color, 50),
              style(e[:text], 30)
          ]
        end
        print_table(tbl, indent: 2)

        puts style(_('Summa summarum (%<date>s):') % {date: date}, :bold)
        tbl = entries[:daily_hours].map do |entrydate, hours|
          planned = entries[:work_hours][:planned]
          on_day = entries[:work_hours][entrydate]
          color = Utils.classify_workhours(hours, planned, on_day)
          ["#{entrydate.strftime("%a")}:", style("#{hours}h / #{planned}h (#{on_day}h)", color)]
        end
        print_table(tbl, indent: 2)

      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'buchen [date]', _('Buchen in Redmine')
      def buchen(date = nil)
        entries = options[:entries] || Buchungsstreber::Context.new(options[:file]).entries[:entries]
        redmines = Redmines.new(Config.load[:redmines]) # FIXME: should be embedded somewhere

        puts style(_('Buche'), :bold)
        entries.select { |e| date.nil? || Date.parse(date) == e[:date] }.each do |entry|
          print style(_('Buche %<time>sh auf %<issue>s: %<text>s') % {time: entry[:time], issue: entry[:issue], text: entry[:text]}, 60)
          $stdout.flush
          redmine = redmines.get(entry[:redmine])
          status = Validator.status!(entry, redmine)
          case
          when status.grep(/(time|activity)_different/).any?
            puts style(_("-> Bereits gebucht")+" (#{status.join(', ')})", :red, :bold)
          when status.include?(:existing)
            puts style('-> Bereits gebucht', :green)
          else
            success = redmine.add_time entry
            puts success ? style(_("-> OK"), :green) : style(_("-> FEHLER"), :red, :bold)
          end
        end

        puts style(_('Buchungen erfolgreich gespeichert'), :green, :bold)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'archivieren', _('Jetzige Eintraege Archiviren')
      def archivieren
        buchungsstreber = Buchungsstreber::Context.new(options[:file])
        entries = options[:entries] || buchungsstreber.entries
        min_date, = entries[:daily_hours].keys.minmax
        archive_path = buchungsstreber.config[:archive_path]
        timesheet_parser = buchungsstreber.timesheet_parser
        timesheet_parser.archive(archive_path, min_date)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'init', _('Konfiguration initialisieren')
      def init
        if (f = Config.find_config)
          puts _('Buchungsstreber bereits konfiguriert in %<file>s') % {file: f}
          exit
        end

        f = init_config
        puts _('Konfiguration in %<file>s erstellt.') % {file: f}
        puts ''
        puts _('Schritte zum friedvollen Buchen:')
        puts _(' * Config-Datei anpassen - mindestens die eigenen API-Keys eintragen.')
        puts _(' * Buchungsdatei oeffnen (siehe Konfig-Datei)')
        puts _(' * `buchungsstreber` ausfuehren')
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'version', _('Version ausgeben')
      def version
        say "v#{Buchungsstreber::VERSION}"
      end

      desc 'config', _('Konfiguration editieren')
      def config
        return $stdout.write(File.read(Config.find_config)) if is_automated?
        Kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', Config.find_config)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'edit [date]', _('Buchungen editieren')
      def edit(date = nil)
        buchungsstreber = Buchungsstreber::Context.new(options[:file])
        timesheet_file = buchungsstreber.timesheet_file

        # If a date is given, generate a new entry if there isn't already one
        if date
          date = Date.parse(date)

          entries = buchungsstreber.entries

          unless entries[:daily_hours].keys.include?(date)
            entries = buchungsstreber.generate(date)
            entries.each do |e|
              buchungsstreber.resolve(e)
              e[:redmine] = nil if buchungsstreber.redmines.default?(e[:redmine])
            end

            parser = buchungsstreber.timesheet_parser
            newday = parser.format(entries)
            prev =  File.read(timesheet_file)
            tmpfile = File.open(timesheet_file, 'w+')
            begin
              tmpfile.write(newday + "\n\n" + prev)
              timesheet_file = tmpfile.path
            ensure
              tmpfile.close
            end
          end
        end

        return $stdout.write(File.read(timesheet_file)) if is_automated?
        Kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', timesheet_file)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'watch [date]', _('Ueberwache aenderungen der Buchungsdatei')
      def watch(date = nil)
        date = Date.parse(date) if date
        buchungsstreber = Buchungsstreber::Context.new(options[:file])

        require_relative 'tui'
        tui = Buchungsstreber::TUI::App.new(buchungsstreber, date, options)
        tui.start
      rescue Interrupt, StandardError => e
        handle_error(e, options[:debug])
      end

      private

      def style(string, *styles)
        styles.compact!
        len = styles.find { |x| x.is_a?(Numeric) }
        styles = styles.select { |x| x.is_a?(Symbol) }
        string = Utils.fixed_length(string, len) if len && !options[:long]
        string = set_color(string, *styles) unless styles.empty? rescue string
        string
      end

      def handle_error(e, debug = false)
        $stderr.puts pretty_error(e, debug)
        exit 1
      end

      def pretty_error(e, debug)
        if !debug
          e.class.name + ': ' + e.message[0..80]
        else
          msg = ['']
          msg << [e.class.name + ': ' + e.message]
          msg << e.backtrace.select { |x| x =~ /buchungsstreber/ }.map { |x| "  " + x }
          msg << '  ...'
          msg.join("\n")
        end
      end

      def is_automated?
        !$stdin.tty? || $stdin.closed? || $stdin.is_a?(StringIO) || !$stdout.tty?
      end

      def init_config
        FileUtils.mkdir_p(Config.user_config_path)

        template = File.expand_path('example.config.yml', __dir__ + '/../../..')
        target = File.expand_path(Config::DEFAULT_NAME, Config.user_config_path)
        timesheet_file = File.expand_path('buchungen.yml', Config.user_config_path)
        archive_path = File.expand_path('archive', Config.user_config_path)

        config = File.read(template)
        config.gsub!(/^(timesheet_file):.*/, "\\1: #{timesheet_file}")
        config.gsub!(/^(archive_path):.*/, "\\1: #{archive_path}")

        File.open(target, "w") { |io| io.write(config) }
        target
      end
    end
  end
end
