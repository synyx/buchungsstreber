class Validator

  def validate(entry, redmine)
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
    if !text || text.strip.length <= 1
      warn "Entry has invalid text: #{entry}"
      return false
    end

    true
  end
end