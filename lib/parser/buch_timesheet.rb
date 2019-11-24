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
            time: $3.to_f,
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
end
