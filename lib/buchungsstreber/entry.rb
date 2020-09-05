require_relative 'validator'

class Entry
  attr_accessor :time, :activity, :issue, :text, :date

  def initialize(time, date, activity = nil, issue = nil, text = nil, redmine = nil)
    @time, @activity, @issue, @text, @date, @redmine = time, activity, issue, text, date, redmine
  end

  def redmine
    Redmines.new(Config.current[:redmines]).get(@redmine)
  end

  def complete?
    @activity.nil? || @issue.nil?
  end

  def valid?
    entry = {
      time: @time,
      activity: @activity,
      issue: @issue,
      text: @text,
      date: @date,
    }
    Validator.new.validate(entry, redmine)
  end
end
