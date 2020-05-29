require 'date'

# BuchTimesheep parses the layout used by jo.
#
class BuchTimesheet
  include TimesheetParser::Base

  def initialize(templates)
  end

  def self.parses?(file)
    return File.extname(file) == '.B'
  end

  def parse(file)
    result = []

    current = nil
    work_hours = nil
    File.readlines(file).each do |line|
      case line
      when /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/
        # beginning of day
        current = $1
        if line =~ /(?<start>\d{1,2}:\d{1,2}) -> (?<pause>\d{1,2}(?:[:.]\d{1,2})?) -> (?<end>\d{1,2}:\d{1,2})/
          s = Time.parse(current + ' ' + $~[:start])
          p = parse_time($~[:pause])
          e = Time.parse(current + ' ' + $~[:end])
          work_hours = qarter_time((e - s) / 60 / 60 - p)
        else
          work_hours = nil
        end
      when /^%/
        # ignore comment lines
        next
      when /(?<redmine>[a-z]?)#(?<issue>[0-9]*)\s\s*(?<time>[0-9]+(?:[.:][0-9]*)?)\s\s*(?<activity>[a-z]+\s+)?(?<text>.+)/i
        result << {
            time: qarter_time(parse_time($~[:time])),
            activity: ($~[:activity] ? $~[:activity].strip : nil),
            issue: $~[:issue],
            text: $~[:text],
            date: parse_date(current),
            redmine: $~[:redmine],
            work_hours: work_hours,
        }
      when /(?<redmine>[a-z]?)#(?<issue>[0-9]*)\s\s*(?<time>[0-9]+(?:[.:][0-9]*)?)/
        result << {
          time: qarter_time(parse_time($~[:time])),
          issue: $~[:issue],
          date: parse_date(current),
          redmine: $~[:redmine],
          work_hours: work_hours,
        }
      when /^$/
        # ignore empty lines
        next
      when /^\s+(.*)/
        # continuation
        result[-1][:text] += $1
      else
        throw "invalid line #{line}"
      end
    end

    result
  end

  def format(entries)
    buf = ""
    days = entries.group_by {|e| e[:date] }.to_a.sort_by { |x| x[0] }
    days.each do |day, entries|
      buf << "#{day}\n\n"
      entries.each do |e|
        buf << "% #{e[:comment]}\n" if e[:comment]
        buf << "#{e[:redmine]}##{e[:issue]}\t#{qarter_time(e[:time] || 0.0)}\t#{e[:activity]}\t#{e[:text]}\n"
      end
    end
    buf
  end

  def archive(file_path, archive_path, date)
    FileUtils.mkdir_p archive_path unless File.directory? archive_path
    archive_filename = date.strftime("%Y-%m-%d") + ".B"

    File.open("#{archive_path}/#{archive_filename}", File::WRONLY | File::CREAT | File::EXCL) do |f|
      f.write(File.read(file_path))
    end
  end

  private

  def parse_date(date_descr)
    Date.parse(date_descr)
  end
end
