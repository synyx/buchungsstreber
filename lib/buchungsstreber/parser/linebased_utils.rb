
class Buchungsstreber::TimesheetParser
  module LineBased

    def read_lines
      File.readlines(@file_path) rescue []
    end

    def add(entries)
      lines = read_lines
      # as entries get added on top, reverse the entries before
      entries.reverse.each do |e|
        days = lines.map
                     .with_index { |line, idx| [Date.parse($1), idx] if line =~ /^(\d\d\d\d-\d\d-\d\d)/ }
                     .compact
                     .sort { |x| x[0] }
                     .reverse

        # Find the line of the day to append to
        idx = days.select {|x| x[0] == e[:date] }.map {|x| x[1] }.first

        # or: Find the line of the day to insert new day before
        nidx = days.select {|x| x[0] < e[:date] }.map {|x| x[1] - 1 }.first

        if idx
          # the specific day was found
          idx += 1 if lines[idx+1] == "\n"
          lines = lines[0..idx] + [format_entry(e)] + lines[idx+1..-1]
        elsif nidx && nidx < 0
          # the new day is the first in the file
          lines.unshift format_day(e[:date]), "\n", format_entry(e), "\n"
        elsif nidx
          # the new day will be inserted between two days
          lines = lines[0..nidx] + [format_day(e[:date]), "\n", format_entry(e), "\n"] + lines[nidx+1..-1]
        else
          # the new day is the first one or the last one
          lines << "\n" unless lines.empty?
          lines << format_day(e[:date])
          lines << "\n"
          lines << format_entry(e)
        end
      end

      lines.join
    end
  end
end
