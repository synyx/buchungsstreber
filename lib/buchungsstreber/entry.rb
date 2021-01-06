require_relative 'validator'

class Buchungsstreber::Entry
  include Comparable

  attr_accessor :time, :activity, :issue, :text, :date, :redmine, :work_hours, :comment, :error

  def initialize(
    date:,
    time: 0,
    activity: nil,
    issue: nil,
    text: nil,
    redmine: nil,
    work_hours: nil,
    comment: nil,
    error: nil
  )
    @time, @activity, @issue, @text, @date, @redmine = time, activity, issue, text, date, redmine
    @work_hours, @comment, @error = work_hours, comment, error
  end

  def [](sym)
    self.respond_to?(sym) or throw "#{sym} not available for entry"
    self.send(sym)
  end

  def []=(sym, val)
    self.respond_to?("#{sym}=".to_sym) or throw "#{sym} not available for entry"
    self.send("#{sym}=".to_sym, val)
  end

  def <=>(o)
    return nil unless o.respond_to?(:[])

    # ignore extra fields, only compare bare minimum
    if @date == o[:date] && @activity == o[:activity] && @issue == o[:issue] && @time == (o[:time]||0) && @redmine == o[:redmine]
      0
    elsif @date > o[:date]
      1
    else
      -1
    end
  end

  def ===(o)
    if o.respond_to?(:first) && o.respond_to?(:last)
      o.include?(@date)
    elsif o.respond_to?(:to_date)
      o.to_date == @date
    else
      self == o
    end
  end

  def to_h
    to_hash
  end

  def to_hash
    [:time, :activity, :issue, :text, :date, :redmine, :work_hours, :comment, :error].inject({}) do |m,s|
      m.merge({s: self.send(s)})
    end
  end
end
