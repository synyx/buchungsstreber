require 'date'

# BuchTimesheep parses the layout used by jo.
#
class BuchTimesheet
  include TimesheetParser::Base

  def initialize(templates)
    @templates = templates
  end

  def self.parses?(file)
    return File.extname(file) == '.B'
  end

  def parse(file)
    result = []

    current = nil
    File.readlines(file).each do |line|
      case line
      when /^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/
        # beginning of day
        current = $1
      when /^%/
        # ignore comment lines
        next
      when /(?<redmine>[a-z]?)#(?<issue>[0-9]*)\s\s*(?<time>[0-9]+(?:[.:][0-9]*)?)\s\s*(?<activity>[a-z]*\s+)?(?<text>.*)/i
        result << {
            time: qarter_time(parse_time($~[:time])),
            activity: ($~[:activity] ? $~[:activity].strip : nil),
            issue: $~[:issue],
            text: $~[:text],
            date: parse_date(current),
            redmine: $~[:redmine]
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

  def archive(file_path, archive_path, date)
    raise 'not implemened'
  end

private

  def parse_date(date_descr)
    Date.parse(date_descr)
  end
end
