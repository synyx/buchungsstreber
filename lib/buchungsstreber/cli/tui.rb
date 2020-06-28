begin
  require 'curses'
rescue
  require 'ffi-ncurses/ncurses'
end
require 'io/console'
require 'yaml'
require_relative '../../buchungsstreber/watcher'

module Buchungsstreber
  module TUI
    class App

      def initialize(buchungsstreber, startdate = nil, options = {})
        @buchungsstreber = buchungsstreber
        @date = startdate
        @options = options
      end

      def start
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
        Curses.init_pair(5, Curses::COLOR_YELLOW, 0) # warning

        @win = Curses.stdscr
        @entries = { entries: [] }

        Signal.trap('SIGWINCH') { setsize }
        Thread.start do
          while true
            on_input(@win.getch)
          end
        end

        setsize
        redraw
        Watcher.watch(@buchungsstreber.timesheet_file) do |_|
          redraw
        end
      ensure
        Curses.close_screen
      end

      private

      def redraw
        loading('🔃')
        Curses.refresh

        e =
            begin
              @entries.merge! @buchungsstreber.entries(@date)
              addstatus('')
              Aggregator.aggregate(@entries[:entries])
            rescue StandardError => e
              addstatus(e.message)
              # redraw old state
              $stderr.puts e if @options[:debug]
              @entries[:entries]
            end

        @win.setpos(2, 0)
        if e.empty?
          @win.attron(Curses::A_BOLD) do
            @win.addstr("%s %sh / %sh\n" % [@date.strftime, 0.0, @entries[:work_hours][@date]])
          end
        end
        dt = nil
        e.each_with_index do |e, i|
          if e[:date] != dt
            dt = e[:date]
            hours = @entries[:entries].select { |x| x[:date] == e[:date] }.map { |x| x[:time] }.sum
            color = color_pair(Utils.classify_workhours(hours, @entries[:work_hours][:planned], @entries[:work_hours][dt]))

            @win.attron(color | Curses::A_BOLD) do
              @win.addstr("%s %sh / %sh\n" % [e[:date].strftime, hours, @entries[:work_hours][dt]])
            end
          end

          status_color = {true => 3, false => 1}[e[:valid]]
          err = e[:errors].map { |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')

          @win.setpos(@win.cury, 2)
          @win.addstr(e[:date].strftime("%a:"))

          @win.setpos(@win.cury, 7)
          @win.attron(Curses::A_BOLD) { @win.addstr("%sh" % e[:time]) }

          @win.setpos(@win.cury, 14)
          @win.addstr(e[:redmine] || '@')

          @win.setpos(@win.cury, 16)
          @win.attron(Curses.color_pair(status_color)) { @win.addstr(style((err || '') + (e[:title] || ''), 50)) }

          @win.setpos(@win.cury, 70)
          @win.addstr(style(e[:text], @win.maxx - 70))

          @win.clrtoeol
        end
        @win.addstr("\n")
        (@win.cury..(@win.maxy-2)).each do |i|
          @win.setpos(i, 0)
          @win.clrtoeol
        end
      rescue StandardError => e
        addstatus(e.message)
      ensure
        loading('  ')
        Curses.refresh
      end

      def detailpage(x, y)
        return unless y > 1 && y < @entries[:entries].length + 2
        w = Curses::Window.new(@win.maxy-4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
        entry = @entries[:entries][y-3]
        w.setpos(2, 2)
        YAML.dump(entry).lines do |line|
          w.setpos(w.cury, 2)
          w.addstr(line)
        end
        w.box("|", "-")
        w.refresh
        w.getch
        w.close
        redraw
      rescue StandardError => e
        addstatus(e.message)
      end

      def buchen(date = nil)
        redmines = @buchungsstreber.redmines
        entries = @entries[:entries].select { |e| date.nil? || date == e[:date] }
        entries = Aggregator.aggregate(entries)

        w = Curses::Window.new(@win.maxy-4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
        w.setpos(2, 2)
        w.attron(Curses::A_BOLD) { w.addstr("Buche\n") }
        w.box("|", "-")
        w.refresh

        entries.each do |entry|
          w.setpos(w.cury+1, 5)
          w.addstr style("Buche #{entry[:time]}h auf \##{entry[:issue]}: #{entry[:text]}", w.maxx - 15)
          w.refresh

          redmine = redmines.get(entry[:redmine])
          status = Validator.status!(entry, redmine)

          case
          when status.grep(/(time|activity)_different/).any?
            success = false
            color = color_pair(:red) | Curses::A_BOLD
            w.attron(color) { w.addstr("→ DIFF #{$1}") }
          when status.include?(:existing)
            success = true
            color = color_pair(:green)
            w.attron(color) { w.addstr("→ ACK") }
          else
            success = redmine.add_time entry
            color = success ? color_pair(:green) : (color_pair(:red) | Curses::A_BOLD)
            w.attron(color) { w.addstr(success ? "→ OK" : "→ FEHLER") }
          end
          w.setpos(w.cury, 3)
          w.attron(color) { w.addstr(success ? '✓' : 'X') }
          w.refresh
        end

        w.setpos(w.cury+2, 2)
        w.addstr "Buchungen abgearbeitet\n"

        w.refresh
        w.getch
        w.close
        redraw
      rescue StandardError => e
        addstatus(e.message)
      end

      def setsize(*args)
        lines, cols = IO.console.winsize
        Curses.resizeterm(lines, cols)
        @win.resize(lines, cols)
        @win.setpos(0, 0)
        @win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
          @win.addstr("    %-#{@win.maxx-4}s" % "BUCHUNGSSTREBER v#{Buchungsstreber::VERSION}")
        end
        @win.setpos(@win.maxy - 1, 0)
        @win.addstr("% #{@win.maxx-2}s  " % ("%d / %d" % [@win.maxy, @win.maxx]))
        Curses.refresh
      end

      def show_help
        addstatus("h/? help | q quit | ↑ next day | ↓ previous day | <enter> refresh")
      end

      def addstatus(msg)
        @win.setpos(@win.maxy - 1, 0)
        @win.addstr(msg)
        @win.clrtoeol
      end

      def loading(l)
        @win.setpos(0, 0)
        @win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
          @win.addstr(l)
        end
      end

      def on_input(keycode)
        case keycode
        when 10
          redraw
        when Curses::KEY_RESIZE
          # Note: this is called incredibly often, use the WINCH trap above
          #setsize.call
        when Curses::KEY_MOUSE
          if (m = Curses.getmouse)
            detailpage(m.x, m.y)
          end
        when Curses::KEY_DOWN
          @date -= 1
          redraw
        when Curses::KEY_UP
          @date += 1
          redraw
        when '?', 'h', Curses::KEY_F1
          show_help
        when 'b'
          buchen(@date)
        when 'q'
          exit 0
        else
          #addstatus('Unknown keycode `%s`' % str.inspect)
        end
      end

      def style(string, *styles)
        styles.compact!
        len = styles.find { |x| x.is_a?(Numeric) }
        string = Utils.fixed_length(string, len) if len && !@options[:long]
        string
      end

      def color_pair(color)
        c = case color
            when :red then 1
            when :green then 2
            when :yellow then 5
            else
              0
            end
        Curses.color_pair(c)
      end
    end
  end
end
