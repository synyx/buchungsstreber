require 'thor'

require 'buchungsstreber'

module Buchungsstreber
  module CLI
    class App < Thor
      class_option :debug, :type => :boolean
      class_option :long, :type => :boolean

      desc '', 'Buchen'
      def execute
        title = "BUCHUNGSSTREBER v#{VERSION}"
        puts style(title, :bold)
        puts '~' * title.length
        puts ''

        unless Config.find_config
          invoke :init
          invoke :config if yes?('Konfiguration editieren?')
        end

        entries = Buchungsstreber.entries
        tbl = entries[:entries].map do |e|
          status_color = {true => :blue, false => :red}[e[:valid]]
          err = e[:errors].map{ |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')
          [
            e[:date].strftime("%a:"),
            style("%sh" % e[:time], :bold),
            '@',
            style(err + e[:title], status_color, 50),
            style(e[:text], 30)
          ]
        end
        print_table(tbl, indent: 2)

        return unless entries[:valid]

        min_date, max_date = entries[:daily_hours].keys.minmax
        puts style("Zu buchende Stunden (#{min_date} bis #{max_date}):", :bold)
        tbl = entries[:daily_hours].map do |date, hours|

          color = Utils.classify_workhours(hours, entries[:work_hours])
          ["#{date.strftime("%a")}:", style("#{hours}h", color)]
        end
        print_table(tbl, indent: 2)

        if is_automated? || yes?('Buchungen in Redmine übernehmen? (y/N)')
          invoke :buchen, [], entries: entries
          invoke :archivieren, [], entries: entries
        end
      rescue Exception => e
        handle_error(e, options[:debug])
      end

      default_task :execute

      desc 'buchen', 'Buchen in Redmine'
      def buchen
        entries = options[:entries] || Buchungsstreber.entries
        redmines = Redmines.new(Config.load[:redmines]) # FIXME: should be embedded somewhere

        puts style('Buche', :bold)
        entries[:entries].each do |entry|
          print style("Buche #{entry[:time]}h auf \##{entry[:issue]}: #{entry[:text]}", 60)
          $stdout.flush
          success = redmines.get(entry[:redmine]).add_time entry
          puts success ? style("→ OK", :green) : style("→ FEHLER", :red, :bold)
        end

        puts style("Buchungen erfolgreich gespeichert", :green, :bold)
      end

      desc 'archivieren', 'Jetzige Eintraege Archiviren'
      def archivieren
        entries = options[:entries] || Buchungsstreber.entries
        min_date, _ = entries[:daily_hours].keys.minmax
        config = Config.load
        archive_path = config[:archive_path]
        timesheet_file = File.expand_path(config[:timesheet_file])
        timesheet_parser = TimesheetParser.new(timesheet_file, config[:templates])
        timesheet_parser.archive(archive_path, min_date)
      end

      desc 'init', 'Konfiguration initialisieren'
      def init
        if (f = Config.find_config)
          puts "Buchungsstreber bereits konfiguriert in #{f}"
          exit
        end

        f = Executor.init_config
        puts "Konfiguration in #{f} erstellt."
        puts ''
        puts 'Schritte zum friedvollen Buchen:'
        puts ' * Config-Datei anpassen – mindestens die eigenen API-Keys eintragen.'
        puts ' * Buchungsdatei oeffnen (siehe Konfig-Datei)'
        puts ' * `buchungsstreber` ausfuehren'
      rescue Exception => e
        handle_error(e, options[:debug])
      end

      desc 'version', 'Version ausgeben'
      def version
        say "v#{Buchungsstreber::VERSION}"
      end

      desc 'config', 'Konfiguration editieren'
      def config
        return $stdout.write(File.read(Config.find_config)) if is_automated?
        Kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', Config.find_config)
      rescue Exception => e
        handle_error(e, options[:debug])
      end

      desc 'edit', 'Buchungen editieren'
      def edit
        return $stdout.write(File.read(Config.load[:timesheet_file])) if is_automated?
        Kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', Config.load[:timesheet_file])
      rescue Exception => e
        handle_error(e, options[:debug])
      end

      private

      def style(string, *styles)
        styles.compact!
        len = styles.find { |x| x.is_a?(Numeric) }
        styles = styles.select { |x| x.is_a?(Symbol) }
        string = Utils.fixed_length(string, len) if len && !options[:long]
        string = set_color(string, *styles) unless styles.empty?
        string
      end

      def handle_error(e, debug = false)
        puts pretty_error(e, debug)
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
        !$stdin.tty? || $stdin.closed? || $stdin.is_a?(StringIO)
      end
    end
  end
end