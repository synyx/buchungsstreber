class Buchungsstreber::Utils
  def self.fixed_length(str, length)
    str ||= ''
    if str.length > length
      str = str[0..length - 3].gsub(/\s\w+\s*$/, "...")
      str[-1] = "." if str[-1] != "."
    end

    str.ljust(length, " ")
  end

  def self.classify_workhours(worked_hours, work_hours, on_day = nil)
    if !on_day.nil? && work_hours != on_day && (worked_hours - on_day).abs > 0.1
      return :red
    end

    time_difference = (work_hours - worked_hours).abs
    if time_difference > 4
      :red
    elsif time_difference > 1
      :yellow
    else
      :default
    end
  end
end
