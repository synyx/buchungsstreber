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
        @colors = {}
      end

      def start
        Curses.init_screen
        Curses.start_color
        Curses.curs_set(0)
        Curses.noecho
        Curses.cbreak
        Curses.stdscr.keypad(true)

        Curses.init_pair(1, Curses::COLOR_RED, 0) # invalid
        @colors[:red] = Curses.color_pair(1)
        Curses.init_pair(2, Curses::COLOR_GREEN, 0) # ok
        @colors[:green] = Curses.color_pair(2)
        Curses.init_pair(3, Curses::COLOR_BLUE, 0) # valid
        @colors[:blue] = Curses.color_pair(3)
        Curses.init_pair(4, Curses::COLOR_BLACK, Curses::COLOR_GREEN) # header
        @colors[:header] = Curses.color_pair(4)
        Curses.init_pair(5, Curses::COLOR_YELLOW, 0) # warning
        @colors[:yellow] = Curses.color_pair(5)

        if Curses.colors > 8
          @buchungsstreber.redmines.each_with_index do |redmine, i|
            if redmine.config['color']
              # hex colors to a range from 0 to 1000
              r, g, b = redmine.config['color'].gsub('#', '').scan(/../).map { |c| (c.hex / 0.255).to_i }
              Curses.init_color(9 + i, r, g, b)
              Curses.init_pair(10 + i, 9 + i, 0)
              @colors[redmine.prefix] = Curses.color_pair(10 + i)
              @colors[nil] = Curses.color_pair(10 + i) if redmine.default?
            end
          end
        end

        @win = Window.new
        @entries = { entries: [], work_hours: {}, }
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
        while (ch = @queue.pop)
          break if ch == 'q' || ch == 'q'.ord
          on_input ch
        end
      ensure
        Curses.echo
        Curses.nocbreak
        Curses.nl
        Curses.close_screen
      end

      private

      def handle_error(error, debug = true)
        $stderr.puts pretty_error(error, debug)
      end

      def pretty_error(error, debug)
        if !debug
          "#{error.class.name}: #{error.message[0..80]}"
        else
          msg = ['']
          msg << ["#{error.class.name}: #{error.message}"]
          msg << error.backtrace.select { |x| x =~ /buchungsstreber/ }.map { |x| "  #{x}" }
          msg << '  ...'
          msg.join("\n")
        end
      end

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
            handle_error(e, @options[:debug])
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

          status_color = {true => :blue, false => :red}[e[:valid]]
          err = e[:errors].map { |x| "<#{x.gsub(/:.*/m, '')}> " }.join('')

          @win.clrtoeol

          @win.setpos(@win.cury, 2)
          @win.addstr(e[:date].strftime("%a:"))

          @win.setpos(@win.cury, 7)
          @win.attron(Curses::A_BOLD) { @win.addstr("%sh" % e[:time]) }

          @win.setpos(@win.cury, 14)
          @win.attron(color_pair(e[:redmine])) { @win.addstr(e[:redmine] || '@') }

          @win.setpos(@win.cury, 16)
          @win.attron(color_pair(status_color)) { @win.addstr(style((err || '') + (e[:title] || ''), 50)) }

          @win.setpos(@win.cury, 70)
          @win.addstr(style(e[:text] || '', @win.maxx - 70))
        end
        @win.addstr("\n")
        (@win.cury..(@win.maxy - 2)).each do |i|
          @win.setpos(i, 0)
          @win.clrtoeol
        end
      rescue StandardError => e
        addstatus(e.message)
        handle_error(e)
      ensure
        loading('  ')
        Curses.refresh
      end

      def detailpage(_x, y)
        return unless y > 1 && y < @entries[:entries].length + 2

        w = Window.new(@win.maxy - 4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
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

        w = Window.new(@win.maxy - 4, (@win.maxx * 0.80).ceil, 2, (@win.maxx * 0.10).ceil)
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
        handle_error(e)
      end

      def generate
        loading(_('&'))

        entries = @buchungsstreber.generate(@date)
        entries.each do |e|
          @buchungsstreber.resolve(e)
          e[:redmine] = nil if @buchungsstreber.redmines.default?(e[:redmine])
        end

        parser = @buchungsstreber.timesheet_parser
        parser.add(entries)
      rescue StandardError => e
        addstatus(e.message)
        handle_error(e)
      ensure
        loading('  ')
      end

      def setsize(*_args)
        lines, cols = IO.console.winsize
        Curses.resizeterm(lines, cols)
        @win.resize(lines, cols)
        @win.setpos(0, 0)
        @win.attron(color_pair(:header) | Curses::A_BOLD) do
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
        @win.attron(color_pair(:header) | Curses::A_BOLD) do
          @win.addstr(l)
        end
        Curses.refresh
      end

      def on_input(keycode)
        if @subwindow
          case keycode
          when ' ', ' '.ord, "\e".ord, Curses::KEY_CANCEL, Curses::KEY_BACKSPACE
            @subwindow.del
            @subwindow = nil
            redraw
          when 'n', 'n'.ord, "\n".ord, Curses::KEY_ENTER
            @date += 1
            @subwindow.del
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
        when 'r', 'r'.ord, Curses::KEY_RESIZE
          setsize
        when Curses::KEY_MOUSE
          if (m = Curses.getmouse)
            @subwindow = detailpage(m.x, m.y)
          end
        when Curses::KEY_DOWN, Curses::KEY_LEFT
          @date -= 1
          redraw
        when 't', 't'.ord
          @date = Date.today
          redraw
        when 'g', 'g'.ord
          generate
          redraw
        when Curses::KEY_UP, Curses::KEY_RIGHT
          @date += 1
          redraw
        when '?', 'h', '?'.ord, 'h'.ord, Curses::KEY_F1, Curses::KEY_HELP
          if @help_shown
            @help_shown = false
            addstatus('')
          else
            @help_shown = true
            show_help
          end
        when 'b', 'b'.ord
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
        @colors[color] || Curses.color_pair(0)
      end
    end

    class Window
      def initialize(win = Curses.stdscr, *args)
        if args.empty?
          @win = win
        else
          nlines, ncols, begin_y, begin_x = win, *args
          @win = Curses.subwin(Curses.stdscr, nlines, ncols, begin_y, begin_x)
          @win.bkgd(Curses.color_pair(0))
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
