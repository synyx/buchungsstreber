
class Buchungsstreber::TimesheetParser
  module LineBased

    def lines
      @lines ||= (File.readlines(@file_path) rescue [])
    end

    def unparse
      lines.join
    end

    def add(entries)
      # as entries get added on top, reverse the entries before
      entries.reverse.each do |e|
        iso_date = e[:date].to_s
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
          @lines = @lines[0..idx] + [format_entry(e)] + @lines[idx+1..-1]
        elsif nidx && nidx < 0
          # the new day is the first in the file
          @lines.unshift "#{iso_date}:\n\n", format_entry(e)
        elsif nidx
          @lines = @lines[0..nidx] + ["#{iso_date}:\n", format_entry(e)] + @lines[nidx+1..-1]
          # the new day will be inserted between two days
        else
          # the new day is the first one
          @lines << "#{iso_date}:\n\n"
          @lines << format_entry(e)
        end
      end
    end
  end
end
