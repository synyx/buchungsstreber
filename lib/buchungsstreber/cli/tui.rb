require 'io/console'
require 'yaml'
require 'ncursesw'

require_relative '../../buchungsstreber/watcher'

module Buchungsstreber
  module TUI
    class App

      def initialize(buchungsstreber, startdate = nil, options = {})
        @buchungsstreber = buchungsstreber
        @date = startdate
        @options = options
        @colors = {}
      end

      def start
        Ncurses.initscr
        Ncurses.start_color
        Ncurses.curs_set(0)
        Ncurses.noecho
        Ncurses.cbreak
        Ncurses.stdscr.keypad(true)

        Ncurses.init_pair(1, Ncurses::COLOR_RED, 0) # invalid
        @colors[:red] = Ncurses.COLOR_PAIR(1)
        Ncurses.init_pair(2, Ncurses::COLOR_GREEN, 0) # ok
        @colors[:green] = Ncurses.COLOR_PAIR(2)
        Ncurses.init_pair(3, Ncurses::COLOR_BLUE, 0) # valid
        @colors[:blue] = Ncurses.COLOR_PAIR(3)
        Ncurses.init_pair(4, Ncurses::COLOR_BLACK, Ncurses::COLOR_GREEN) # header
        @colors[:header] = Ncurses.COLOR_PAIR(4)
        Ncurses.init_pair(5, Ncurses::COLOR_YELLOW, 0) # warning
        @colors[:yellow] = Ncurses.COLOR_PAIR(5)

        if Ncurses.COLORS > 8
          @buchungsstreber.redmines.each_with_index do |redmine, i|
            if redmine.config['color']
              # hex colors to a range from 0 to 1000
              r, g, b = redmine.config['color'].gsub('#', '').scan(/../).map { |c| (c.hex / 0.255).to_i }
              Ncurses.init_color(9 + i, r, g, b)
              Ncurses.init_pair(10 + i, 9 + i, 0)
              @colors[redmine.prefix] = Ncurses.COLOR_PAIR(10 + i)
              @colors[nil] = Ncurses.COLOR_PAIR(10 + i) if redmine.default?
            end
          end
        end

        @win = Window.new
        @entries = { entries: [] }
        @queue = Queue.new

        Signal.trap('SIGWINCH') { @queue << 'r' }
        Thread.start do
          loop do
            @queue << Ncurses.getch
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
        while (ch = @queue.pop) != 'q'.ord
          on_input ch
        end
      ensure
        Ncurses.echo
        Ncurses.nocbreak
        Ncurses.nl
        Ncurses.endwin
      end

      private

      def redraw
        loading(_('&'))
        Ncurses.refresh

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

        @win.move(2, 0)
        if e.empty?
          @win.attron(Ncurses::A_BOLD) do
            @win.addstr("%s %sh / %sh\n" % [@date.strftime, 0.0, @entries[:work_hours][@date]])
          end
        end
        dt = nil
        e.each_with_index do |e, _i|
          if e[:date] != dt
            dt = e[:date]
            hours = @entries[:entries].select { |x| x[:date] == e[:date] }.map { |x| x[:time] }.sum
            color = color_pair(Utils.classify_workhours(hours, @entries[:work_hours][:planned], @entries[:work_hours][dt]))

            @win.attron(color | Ncurses::A_BOLD) do
              @win.addstr("%s %sh / %sh\n" % [e[:date].strftime, hours, @entries[:work_hours][dt]])
            end
          end

          status_color = {true => :blue, false => :red}[e[:valid]]
          err = e[:errors].map { |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')

          @win.clrtoeol

          @win.move(@win.getcury, 2)
          @win.addstr(e[:date].strftime("%a:"))

          @win.move(@win.getcury, 7)
          @win.attron(Ncurses::A_BOLD) { @win.addstr("%sh" % e[:time]) }

          @win.move(@win.getcury, 14)
          @win.attron(color_pair(e[:redmine])) { @win.addstr(e[:redmine] || '@') }

          @win.move(@win.getcury, 16)
          @win.attron(color_pair(status_color)) { @win.addstr(style((err || '') + (e[:title] || ''), 50)) }

          @win.move(@win.getcury, 70)
          @win.addstr(style(e[:text], @win.getmaxx - 70))
        end
        @win.addstr("\n")
        (@win.getcury..(@win.getmaxy - 2)).each do |i|
          @win.move(i, 0)
          @win.clrtoeol
        end
      rescue StandardError => e
        addstatus(e.message)
      ensure
        loading('  ')
        Ncurses.refresh
      end

      def detailpage(_x, y)
        return unless y > 1 && y < @entries[:entries].length + 2

        w = Window.new(@win.getmaxy - 4, (@win.getmaxx * 0.80).ceil, 2, (@win.getmaxx * 0.10).ceil)
        entry = Aggregator.aggregate(@entries[:entries])[y - 3]
        w.move(2, 2)
        YAML.dump(entry).lines do |line|
          w.move(w.getcury, 2)
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

        w = Window.new(@win.getmaxy - 4, (@win.getmaxx * 0.80).ceil, 2, (@win.getmaxx * 0.10).ceil)
        w.move(2, 2)
        w.attron(Ncurses::A_BOLD) { w.addstr(_('Buche')) }
        w.box(0, 0)
        w.refresh

        entries.each do |entry|
          w.move(w.getcury + 1, 5)
          w.addstr style(_('Buche %<time>sh auf %<issue>s: %<text>s') % entry, w.getmaxx - 21)
          w.refresh

          redmine = redmines.get(entry[:redmine])
          status = Validator.status!(entry, redmine)

          if status.grep(/(time|activity)_different/).any?
            success = false
            color = color_pair(:yellow) | Ncurses::A_BOLD
            w.attron(color) { w.addstr(_('-> DIFF') + " #{$1}") }
          elsif status.include?(:existing)
            success = true
            color = color_pair(:green)
            w.attron(color) { w.addstr(_('-> ACK')) }
          else
            success = redmine.add_time entry
            color = success ? color_pair(:green) : (color_pair(:red) | Ncurses::A_BOLD)
            w.attron(color) { w.addstr(success ? _('-> OK') : _('-> FEHLER')) }
          end
          w.move(w.getcury, 3)
          w.attron(color) { w.addstr(success ? _('o') : _('x')) }
          w.refresh
        end

        w.move(w.getcury + 2, 2)
        w.addstr _('Buchungen abgearbeitet')

        w.refresh
        w
      rescue StandardError => e
        addstatus(e.message)
      end

      def generate
        loading(_('&'))

        entries = @buchungsstreber.entries(@date)
        timesheet_file = @buchungsstreber.timesheet_file

        if entries[:entries].empty?
          entries = @buchungsstreber.generate(@date)
          entries.each do |e|
            @buchungsstreber.resolve(e)
            e[:redmine] = nil if @buchungsstreber.redmines.default?(e[:redmine])
          end

          parser = @buchungsstreber.timesheet_parser
          newday = parser.format(entries)
          FileUtils.cp(timesheet_file, "#{timesheet_file}~")
          prev =  File.read(timesheet_file)
          tmpfile = File.open(timesheet_file, 'w+')
          begin
            tmpfile.write("#{newday}\n\n#{prev}")
          ensure
            tmpfile.close
          end
        end
      rescue StandardError => e
        addstatus(e.message)
      ensure
        loading('  ')
      end

      def setsize(*_args)
        lines, cols = IO.console.winsize
        Ncurses.resizeterm(lines, cols)
        @win.resize(lines, cols)
        @win.move(0, 0)
        @win.attron(color_pair(:header) | Ncurses::A_BOLD) do
          @win.addstr("    %-#{@win.getmaxx - 4}s" % "BUCHUNGSSTREBER v#{Buchungsstreber::VERSION}")
        end
        @win.move(@win.getmaxy - 1, 0)
        @win.addstr("% #{@win.getmaxx - 2}s  " % ("%d / %d" % [@win.getmaxy, @win.getmaxx]))
        Ncurses.refresh
      end

      def show_help
        addstatus(_("h/? help | q quit | l next day | t today | r previous day | <enter> refresh"))
      end

      def addstatus(msg)
        @win.move(@win.getmaxy - 1, 0)
        @win.addstr(msg)
        @win.clrtoeol
        Ncurses.refresh
      end

      def loading(l)
        @win.move(0, 0)
        @win.attron(color_pair(:header) | Ncurses::A_BOLD) do
          @win.addstr(l)
        end
        Ncurses.refresh
      end

      def on_input(keycode)
        if @subwindow
          case keycode
          when Ncurses::KEY_ENTER, ' ', "\e", Ncurses::KEY_CANCEL, Ncurses::KEY_BACKSPACE
            @subwindow.close
            @subwindow = nil
            redraw
          else
            # ignore other keycodes
          end
          return
        end

        case keycode
        when "\n".ord
          redraw
        when 'r'.ord # Ncurses::KEY_RESIZE
          setsize
        when Ncurses::KEY_MOUSE
          if (m = Ncurses.getmouse)
            @subwindow = detailpage(m.x, m.y)
          end
        when Ncurses::KEY_DOWN, Ncurses::KEY_LEFT
          @date -= 1
          redraw
        when 't'.ord
          @date = Date.today
          redraw
        when 'g'.ord
          generate
          redraw
        when Ncurses::KEY_UP, Ncurses::KEY_RIGHT
          @date += 1
          redraw
        when '?'.ord, 'h'.ord, Ncurses::KEY_F1, Ncurses::KEY_HELP
          if @help_shown
            @help_shown = false
            addstatus('')
          else
            @help_shown = true
            show_help
          end
        when 'b'.ord
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
        @colors[color] || Ncurses.COLOR_PAIR(0)
      end
    end

    class Window
      def initialize(win = Ncurses.stdscr, *args)
        if args.empty?
          @win = win
        else
          nlines, ncols, begin_y, begin_x = win, *args
          @win = Ncurses.subwin(Ncurses.stdscr, nlines, ncols, begin_y, begin_x)
          @win.bkgd(Ncurses.COLOR_PAIR(0))
          @win.clear
          @win.box(0, 0)
        end
      end

      def attron(*args, &block)
        @win.attron(*args)
        block.call
        @win.attroff(*args)
      end

      def method_missing(symbol, *args, &block)
        @win.send(symbol, *args, &block)
      end
    end
  end
end
