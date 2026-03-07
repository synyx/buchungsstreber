class Buchungsstreber::Validator
  def self.validate(entry, redmine, config = {})
    date = entry[:date]
    unless date
      warn "Entry is missing date: #{entry}"
      return false
    end
    if date > Date.today
      warn "Entry has date from the future: #{entry}"
      return false
    end

    time = entry[:time]
    unless time
      warn "Entry has missing time: #{entry}"
      return false
    end
    if !time || time <= 0 || time > 16 || (time * 4).modulo(1) != 0
      warn "Entry has invalid time: #{entry}"
      return false
    end

    activity = entry[:activity]
    unless activity
      warn "Entry is missing activity: #{entry}"
      return false
    end
    unless redmine.valid_activity? entry[:activity]
      warn "Entry has invalid activity: #{entry}"
      return false
    end

    issue = entry[:issue]
    unless issue
      warn "Entry is missing issue: #{entry}"
      return false
    end
    issue_i = issue.to_i
    if !issue_i || issue_i <= 0
      warn "Entry has invalid issue: #{entry}"
      return false
    end

    text = entry[:text]
    allow_empty_text = config[:allow_empty_text] || false
    if !allow_empty_text && (!text || text.strip.length <= 1)
      warn "Entry has invalid text: #{entry}"
      return false
    end

    true
  end

  def self.status!(entry, redmine)
    times = redmine.get_times(entry[:date])
    return [:missing] unless times

    redmine_entries = times.select { |t| t[:issue].to_s == entry[:issue].to_s }
    return [:missing] if redmine_entries.empty?

    redmine_entries.each_with_object([]) do |redmine_entry, memo|
      entry[:id] = redmine_entry[:id]
      if redmine_entry[:text] != entry[:text]
        # assume different entry
      elsif redmine_entry[:time] != entry[:time]
        memo << :time_different
      elsif !redmine.same_activity?(redmine_entry[:activity], entry[:activity])
        memo << :activity_different
      else
        memo << :existing
      end
    end.sort.uniq
  end
end
