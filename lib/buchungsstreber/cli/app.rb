require 'thor'

require 'buchungsstreber'

module Buchungsstreber
  module CLI
    class App < Thor
      class_option :debug, :type => :boolean
      class_option :long, :type => :boolean

      desc 'buchen [file]', 'Buchung durchfuehren'
      method_options config: :string
      def buchen(file = nil)
        e = Executor.new(file, options[:config])

        e.print_title
        e.show_overview
        if e.valid? and (is_automated? or e.actualize?)
          e.save_entries
          e.archive
        end
      rescue Exception => e
        handle_error(e, options[:debug])
      end

      desc '', 'Buchen'
      def execute
        unless Config.find_config
          invoke :init
          invoke :config if yes?('Konfiguration editieren?')
        end

        entries = Buchungsstreber.entries
        tbl = entries[:entries].map do |e|
          [
            e[:date].strftime("%a:"),
            style("#{e[:time]}h", :bold),
            '@',
            style("#{e[:verr]}#{e[:title]}", {true => :blue, false => :red}[e[:valid]], 50),
            style(e[:text], 30)
          ]
        end
        print_table(tbl, indent: 2)
      end

      default_task :execute

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
        len = styles.find { |x| x.is_a?(Numeric) }
        string = Utils.fixed_length(string, len) if len && !options[:long]
        set_color(string, *styles.select { |x| x.is_a?(Symbol) })
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