require 'thor'

require 'buchungsstreber'

module Buchungsstreber
  module CLI
    class App < Thor

      desc 'buchen [file]', 'Buchung durchfuehren'
      method_options config: :string, aliases: '-c', required: false
      method_options debug: :boolean, aliases: '-d', required: false, lazy_default: true

      def execute(file = nil)
        e = Executor.new(file, options[:config])

        e.print_title
        e.show_overview
        if e.valid? and e.actualize?
          e.save_entries
          e.archive
        end
      rescue Exception => e
        puts pretty_error(e, options[:debug])
      end

      default_task :execute

      desc 'init', 'Konfiguration initialisieren'
      method_options debug: :boolean, aliases: '-d', required: false, lazy_default: true

      def init
        if (f = Config.find_config)
          puts "Buchungsstreber bereits konfiguriert in #{f}"
          return
        end

        f = Executor.init_config
        puts "Konfiguration in #{f} erstellt."
        puts ''
        puts 'Schritte zum friedvollen Buchen:'
        puts ' * Config-Datei anpassen – mindestens die eigenen API-Keys eintragen.'
        puts ' * Buchungsdatei oeffnen (siehe Konfig-Datei)'
        puts ' * `buchungsstreber` ausfuehren'
      rescue Exception => e
        puts pretty_error(e, options[:debug])
      end

      desc 'version', 'Version ausgeben'

      def version
        puts Buchungsstreber::VERSION
      end

      desc 'config', 'Konfiguration editieren'

      def config
        @@kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', Config.find_config)
      end

      desc 'edit', 'Buchungen editieren'

      def edit
        @@kernel.exec(ENV['EDITOR'] || '/usr/bin/vim', Config.load[:timesheet_file])
      end

      private

      def pretty_error(e, debug = false)
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
    end
  end
end