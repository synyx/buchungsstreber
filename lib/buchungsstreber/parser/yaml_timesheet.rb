require "yaml"
require "date"
require "time"

require_relative '../entry'

class Buchungsstreber::YamlTimesheet
  include Buchungsstreber::TimesheetParser::Base

  def initialize(file, templates, minimum_time)
    @file_path = file
    @templates = templates
    @minimum_time = minimum_time

    @model = File.readlines(@file_path) rescue []
  end

  def self.parses?(file)
    %w[.yml .yaml].include?(File.extname(file))
  end

  def parse
    if YAML.respond_to?(:safe_load_file)
      timesheet = YAML.safe_load_file(@file_path, permitted_classes: [Date, Symbol], fallback: {})
    else
      timesheet = YAML.load_file(@file_path, {})
    end
    throw 'invalid line: file should contain map' unless timesheet.is_a?(Hash)
    result = Buchungsstreber::Entries.new

    timesheet.each do |date, entries|
      next if entries.nil?

      throw 'invalid line: entries should be an array' unless entries.is_a?(Array)

      entries.each do |entry|
        result << parse_entry(entry, date)
      end
    end
    result
  end

  def add(entries)
    # as entries get added on top, reverse the entries before
    entries.reverse.each do |e|
      iso_date = e[:date].to_s
      days = @model.map
                   .with_index { |line, idx| [Date.parse($1), idx] if line =~ /^(\d\d\d\d-\d\d-\d\d)/ }
                   .compact
                   .sort { |x| x[0] }
                   .reverse

      # Find the line of the day to append to
      idx = days.select {|x| x[0] == e[:date] }.map {|x| x[1] }.first

      # or: Find the line of the day to insert new day before
      nidx = days.select {|x| x[0] < e[:date] }.map {|x| x[1] - 1 }.first

      if idx
        @model = @model[0..idx] + [format_entry(e)] + @model[idx+1..-1]
      elsif nidx && nidx < 0
        @model.unshift "#{iso_date}:\n\n", format_entry(e)
      elsif nidx
        @model = @model[0..nidx] + ["#{iso_date}:\n", format_entry(e)] + @model[nidx+1..-1]
      else
        @model << "#{iso_date}:\n\n"
        @model << format_entry(e)
      end
    end
  end

  def unparse
    @model.join
  end

  def archive(archive_path, date)
    old_timesheet = ""
    File.read(@file_path).each_line do |line|
      break if line.start_with? "---"

      old_timesheet += line
    end

    FileUtils.mkdir archive_path unless File.directory? archive_path
    archive_filename = "#{date.strftime('%Y-%m-%d')}.yml"
    File.write("#{archive_path}/#{archive_filename}", old_timesheet)

    next_monday = (Date.today + ((1 - Date.today.wday) % 7)).strftime("%Y-%m-%d")
    File.write(@file_path, "#{next_monday}:\n\n\n---\n# Letzte Woche\n" + old_timesheet)
  end

  def format(entries)
    buf = ""
    days = entries.group_by { |e| e[:date] }.to_a.sort_by { |x| x[0] }
    days.each do |date, day|
      buf << "#{date}:\n"
      day.each do |e|
        buf << format_entry(e)
      end
    end
    buf
  end

  def parse_entry(entry, date)
    time, activity, issue_ref, text = entry.to_s.split(/\s+/, 4)

    if @templates.key? activity
      template = @templates[activity]
      activity = template["activity"]
      issue_ref ||= template["issue"].to_s
      text ||= template["text"]
    end

    activity, issue_ref = nil, activity if !issue_ref && activity =~ /^([a-z]*)(\d+)$/i

    _, redmine, issue = issue_ref.match(/^([a-z]*)(\d+)$/i).to_a if issue_ref

    raise "invalid line: #{entry}" unless time
    err = "missing issue #{entry}" unless issue

    Buchungsstreber::Entry.new(
      time: minimum_time(parse_time(time), @minimum_time),
      activity: activity,
      issue: issue,
      text: text,
      date: date,
      redmine: redmine,
      errors: err,
    )
  end

  private

  def format_entry(e)
    buf = ''
    buf << "  # #{e[:comment]}\n" if e[:comment]
    buf << "  - #{minimum_time(e[:time] || 0.0, @minimum_time)}\t#{e[:activity]}\t#{e[:redmine]}#{e[:issue]}\t#{e[:text]}\n"
    buf
  end
end
