require 'date'

# BuchTimesheep parses the layout used by jo.
#
class BuchTimesheet

  def initialize(templates)
    @templates = templates
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
            time: parse_time($~[:time]),
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
        throw "bad line #{line}"
      end
    end

    result
  end

private

  def parse_time(time_descr)
    case time_descr
    when /(\d+):(\d+)/
      hours = $1.to_i
      minutes = $2.to_i
      hours + minutes / 60.0
    when /\d+\.\d+/
      time_descr.to_f
    end
  end

  def parse_date(date_descr)
    Date.parse(date_descr)
  end
end
