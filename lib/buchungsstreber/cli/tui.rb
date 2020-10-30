require 'io/console'
require 'yaml'
require 'curses'

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
        @queue = Queue.new

        Signal.trap('SIGWINCH') { @queue << 'r' }
        Thread.start do
          loop do
            @queue << Curses.getch
          end
        end

        setsize
        redraw

        Thread.start do
          Watcher.watch(@buchungsstreber.timesheet_file) do |_|
            # Refresh (ignored on sub-window)
            @queue << 10
          end
        end

        # Main UI loop
        while (ch = @queue.pop) != 'q'
          on_input ch
        end
      ensure
        Curses.close_screen
      end

      private

      def redraw
        loading(_('&'))
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
        e.each_with_index do |e, _i|
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

          @win.clrtoeol

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
        end
        @win.addstr("\n")
        (@win.cury..(@win.maxy - 2)).each do |i|
          @win.setpos(i, 0)
          @win.clrtoeol
        end
      rescue StandardError => e
        addstatus(e.message)
      ensure
        loading('  ')
        Curses.refresh
      end

      def detailpage(_x, y)
        return unless y > 1 && y < @entries[:entries].length + 2

        w = Curses::Window.new(@win.maxy - 4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
        entry = Aggregator.aggregate(@entries[:entries])[y - 3]
        w.setpos(2, 2)
        YAML.dump(entry).lines do |line|
          w.setpos(w.cury, 2)
          w.addstr(line)
        end
        w.box(0, 0)
        w.refresh
        w
      rescue StandardError => e
        addstatus(e.message)
      end

      def buchen(date = nil)
        redmines = @buchungsstreber.redmines
        entries = @entries[:entries].select { |e| date.nil? || date == e[:date] }
        entries = Aggregator.aggregate(entries)

        w = Curses::Window.new(@win.maxy - 4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
        w.setpos(2, 2)
        w.attron(Curses::A_BOLD) { w.addstr(_('Buche')) }
        w.box(0, 0)
        w.refresh

        entries.each do |entry|
          w.setpos(w.cury + 1, 5)
          w.addstr style(_('Buche %<time>sh auf %<issue>s: %<text>s') % entry, w.maxx - 21)
          w.refresh

          redmine = redmines.get(entry[:redmine])
          status = Validator.status!(entry, redmine)

          if status.grep(/(time|activity)_different/).any?
            success = false
            color = color_pair(:yellow) | Curses::A_BOLD
            w.attron(color) { w.addstr(_('-> DIFF') + " #{$1}") }
          elsif status.include?(:existing)
            success = true
            color = color_pair(:green)
            w.attron(color) { w.addstr(_('-> ACK')) }
          else
            success = redmine.add_time entry
            color = success ? color_pair(:green) : (color_pair(:red) | Curses::A_BOLD)
            w.attron(color) { w.addstr(success ? _('-> OK') : _('-> FEHLER')) }
          end
          w.setpos(w.cury, 3)
          w.attron(color) { w.addstr(success ? _('o') : _('x')) }
          w.refresh
        end

        w.setpos(w.cury + 2, 2)
        w.addstr _('Buchungen abgearbeitet')

        w.refresh
        w
      rescue StandardError => e
        addstatus(e.message)
      end

      def setsize(*_args)
        lines, cols = IO.console.winsize
        Curses.resizeterm(lines, cols)
        @win.resize(lines, cols)
        @win.setpos(0, 0)
        @win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
          @win.addstr("    %-#{@win.maxx - 4}s" % "BUCHUNGSSTREBER v#{Buchungsstreber::VERSION}")
        end
        @win.setpos(@win.maxy - 1, 0)
        @win.addstr("% #{@win.maxx - 2}s  " % ("%d / %d" % [@win.maxy, @win.maxx]))
        Curses.refresh
      end

      def show_help
        addstatus(_("h/? help | q quit | l next day | t today | r previous day | <enter> refresh"))
      end

      def addstatus(msg)
        @win.setpos(@win.maxy - 1, 0)
        @win.addstr(msg)
        @win.clrtoeol
        Curses.refresh
      end

      def loading(l)
        @win.setpos(0, 0)
        @win.attron(Curses.color_pair(4) | Curses::A_BOLD) do
          @win.addstr(l)
        end
      end

      def on_input(keycode)
        if @subwindow
          case keycode
          when Curses::KEY_ENTER, ' ', "\e", Curses::KEY_CANCEL, Curses::KEY_BACKSPACE
            @subwindow.close
            @subwindow = nil
            redraw
          else
            # ignore other keycodes
          end
          return
        end

        case keycode
        when 10
          redraw
        when 'r' # Curses::KEY_RESIZE
          setsize
        when Curses::KEY_MOUSE
          if (m = Curses.getmouse)
            @subwindow = detailpage(m.x, m.y)
          end
        when Curses::KEY_DOWN, Curses::KEY_LEFT
          @date -= 1
          redraw
        when 't'
          @date = Date.today
          redraw
        when Curses::KEY_UP, Curses::KEY_RIGHT
          @date += 1
          redraw
        when '?', 'h', Curses::KEY_F1, Curses::KEY_HELP
          if @help_shown
            @help_shown = false
            addstatus('')
          else
            @help_shown = true
            show_help
          end
        when 'b'
          @subwindow = buchen(@date)
        else
          # addstatus('Unknown keycode `%s`' % str.inspect)
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
