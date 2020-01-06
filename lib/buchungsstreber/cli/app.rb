require 'thor'
require 'tempfile'

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

        entries = Buchungsstreber::Context.new.entries
        aggregated = Aggregator.aggregate(entries[:entries])
        tbl = aggregated.map do |e|
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
          invoke :buchen, [], entries: aggregated
          invoke :archivieren, [], entries: entries
        end
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      default_task :execute

      desc 'buchen', 'Buchen in Redmine'
      def buchen
        entries = options[:entries] || Buchungsstreber::Context.new.entries[:entries]
        redmines = Redmines.new(Config.load[:redmines]) # FIXME: should be embedded somewhere

        puts style('Buche', :bold)
        entries.each do |entry|
          print style("Buche #{entry[:time]}h auf \##{entry[:issue]}: #{entry[:text]}", 60)
          $stdout.flush
          success = redmines.get(entry[:redmine]).add_time entry
          puts success ? style("→ OK", :green) : style("→ FEHLER", :red, :bold)
        end

        puts style("Buchungen erfolgreich gespeichert", :green, :bold)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'archivieren', 'Jetzige Eintraege Archiviren'
      def archivieren
        buchungsstreber = Buchungsstreber::Context.new
        entries = options[:entries] || buchungsstreber.entries
        min_date, = entries[:daily_hours].keys.minmax
        archive_path = buchungsstreber.config[:archive_path]
        timesheet_parser = buchungsstreber.timesheet_parser
        timesheet_parser.archive(archive_path, min_date)
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'init', 'Konfiguration initialisieren'
      def init
        if (f = Config.find_config)
          puts "Buchungsstreber bereits konfiguriert in #{f}"
          exit
        end

        f = init_config
        puts "Konfiguration in #{f} erstellt."
        puts ''
        puts 'Schritte zum friedvollen Buchen:'
        puts ' * Config-Datei anpassen – mindestens die eigenen API-Keys eintragen.'
        puts ' * Buchungsdatei oeffnen (siehe Konfig-Datei)'
        puts ' * `buchungsstreber` ausfuehren'
      rescue StandardError => e
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
      rescue StandardError => e
        handle_error(e, options[:debug])
      end

      desc 'edit [date]', 'Buchungen editieren'
      def edit(date = nil)
        buchungsstreber = Buchungsstreber::Context.new
        config = buchungsstreber.config
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

      desc 'watch', 'Watch the time entry file'
      def watch
        require 'curses'
        require 'io/console'
        require 'yaml'
        require_relative '../../buchungsstreber/watcher'
        Curses.init_screen
        Curses.start_color
        Curses.curs_set(0)
        Curses.noecho
        Curses.mousemask(Curses::BUTTON1_CLICKED)
        Curses.crmode
        Curses.stdscr.keypad(true)

        Curses.init_pair(1, Curses::COLOR_RED, 0) # invalid
        Curses.init_pair(2, Curses::COLOR_GREEN, 0) # ok
        Curses.init_pair(3, Curses::COLOR_BLUE, 0) # valid
        Curses.init_pair(4, Curses::COLOR_BLACK, Curses::COLOR_GREEN) # header

        win = Curses.stdscr

        addstatus = lambda do |msg|
          win.setpos(win.maxy - 1, 0)
          win.addstr(msg)
          win.clrtoeol
        end

        loading = lambda do |l|
          win.setpos(0, 0)
          win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
            win.addstr(l)
          end
        end

        setsize = lambda do |*_|
          lines, cols = IO.console.winsize
          Curses.resizeterm(lines, cols)
          win.resize(lines, cols)
          win.setpos(0, 0)
          win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
            win.addstr("    %-#{win.maxx-4}s" % "BUCHUNGSSTREBER v#{Buchungsstreber::VERSION}")
          end
          win.setpos(win.maxy - 1, 0)
          win.addstr("% #{win.maxx-2}s  " % ("%d / %d" % [win.maxy, win.maxx]))
          Curses.refresh
        end

        buchungsstreber = Buchungsstreber::Context.new
        entries = { entries: [] }
        redraw = lambda do |buchungsstreber|
          loading.call('🔃')
          Curses.refresh

          e =
            begin
              entries.merge! buchungsstreber.entries
              addstatus.call('')
              Aggregator.aggregate(entries[:entries])
            rescue StandardError => e
              addstatus.call(e.message)
              # redraw old state
              $stderr.puts e
              entries[:entries]
            end

          e.each_with_index do |e, i|
            status_color = {true => 3, false => 1}[e[:valid]]
            err = e[:errors].map { |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')

            win.setpos(i + 2, 2)
            win.addstr(e[:date].strftime("%a:"))

            win.setpos(i + 2, 7)
            win.attron(Curses::A_BOLD) { win.addstr("%sh" % e[:time]) }

            win.setpos(i + 2, 14)
            win.addstr('@')

            win.setpos(i + 2, 16)
            win.attron(Curses.color_pair(status_color)) {  win.addstr(style(err + e[:title], 50)) }

            win.setpos(i + 2, 70)
            win.addstr(style(e[:text], win.maxx - 70))

            win.clrtoeol
          end
          win.addstr("\n")
          (win.cury..(win.maxy-2)).each do |i|
            win.setpos(i, 0)
            win.clrtoeol
          end
          loading.call('  ')
          Curses.refresh
        end

        detailpage = lambda do |buchungsstreber, _, y|
          begin
            return unless y > 1 && y < entries[:entries].length + 2
            w = Curses::Window.new(win.maxy-4, (win.maxx * 0.80).ceil, 2, (win.maxx * 0.10).ceil)
            entry = entries[:entries][y-2]
            w.setpos(2, 2)
            YAML.dump(entry).lines do |line|
              w.setpos(w.cury, 2)
              w.addstr(line)
            end
            w.box("|", "-")
            w.refresh
            addstatus.call([y, y-2].inspect)
            w.getch
            w.close
            redraw.call(buchungsstreber)
          rescue StandardError => e
            addstatus.call(e.message)
          end
        end

        redraw.call(buchungsstreber)
        setsize.call

        Signal.trap('SIGWINCH', setsize)
        Thread.start(buchungsstreber) do |buchungsstreber|
          while true
            str = win.getch
            case str
            when 10
              redraw.call(buchungsstreber)
            when Curses::KEY_RESIZE
              # Note: this is called incredibly often, use the WINCH trap above
              #setsize.call
            when Curses::KEY_MOUSE
              if (m = Curses.getmouse)
                addstatus.call([m.x, m.y, m.z, '0x%x' % m.bstate].inspect)
                detailpage.call(buchungsstreber, m.x, m.y)
              end
            when 'q'
              exit 0
            else
              #addstatus.call('Unknown keycode `%s`' % str.inspect)
            end
          end
        end
        Watcher.watch(buchungsstreber.timesheet_file) do |f|
          redraw.call(buchungsstreber)
        end
      rescue Interrupt, StandardError => e
        handle_error(e, options[:debug])
      ensure
        Curses.close_screen
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
