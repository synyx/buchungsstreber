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
      when /([a-z]?)#([0-9]*)\s\s*([0-9]+(?:[.:][0-9]*)?)\s\s*([a-zA-Z]*\t)?(.*)/i
        result << {
            time: parse_time($3),
            activity: $4,
            issue: $2,
            text: $5,
            date: current,
            redmine: $1
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
end
