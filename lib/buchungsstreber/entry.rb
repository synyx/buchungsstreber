require_relative 'validator'

class Buchungsstreber::Entry
  include Comparable

  attr_accessor :time, :activity, :issue, :text, :date, :redmine, :work_hours, :comment, :errors

  def initialize(
    date:,
    time: 0,
    activity: nil,
    issue: nil,
    text: nil,
    redmine: nil,
    work_hours: nil,
    comment: nil,
    errors: nil
  )
    @time, @activity, @issue, @text, @date, @redmine = time, activity, issue, text, date, redmine
    @work_hours, @comment, @errors = work_hours, comment, [errors].flatten
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
    elsif o[:date] && @date > o[:date]
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
    [:time, :activity, :issue, :text, :date, :redmine, :work_hours, :comment, :errors].inject({}) do |m,s|
      m.merge({s: self.send(s)})
    end
  end
end

class Buchungsstreber::Entries
  include Enumerable

  attr_reader :file_path

  def initialize
    @entries = []
  end

  def <<(entry)
    entry = Buchungsstreber::Entry.new(**entry) unless entry.is_a?(Buchungsstreber::Entry)
    @entries << entry
    self
  end

  def method_missing(symbol, *args, &block)
    @entries.send(symbol, *args, &block)
  end

  def empty?
    @entries.empty?
  end
end
