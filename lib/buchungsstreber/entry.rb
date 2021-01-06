require_relative 'validator'

class Entry
  attr_accessor :time, :activity, :issue, :text, :date, :redmine, :work_hours, :comment

  def initialize(
    time:,
    date:,
    activity: nil,
    issue: nil,
    text: nil,
    redmine: nil,
    work_hours: nil,
    comment: nil
  )
    @time, @activity, @issue, @text, @date, @redmine = time, activity, issue, text, date, redmine
    @work_hours, @comment = work_hours, comment
  end

  def [](sym)
    self.respond_to?(sym) or throw "#{sym} not available for entry"
    self.send(sym)
  end

  def []=(sym, val)
    self.respond_to?("#{sym}=".to_sym) or throw "#{sym} not available for entry"
    self.send("#{sym}=".to_sym, val)
  end
end
