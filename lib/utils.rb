class Utils

  def self.fixed_length(str, length)
    if str.length > length
      str = str[0..length - 1].gsub(/\s\w+\s*$/, "…")
    end

    str.ljust(length, " ")
  end

  def self.classify_workhours(worked_hours, config)
    time_difference = (config[:hours] - worked_hours).abs
    if time_difference > 4
      :red
    elsif time_difference > 1
      :yellow
    else
      :default
    end
  end
end
