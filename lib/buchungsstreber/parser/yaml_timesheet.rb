require "yaml"
require "date"
require "time"

class YamlTimesheet
  include TimesheetParser::Base

  def initialize(templates)
    @templates = templates
  end

  def self.parses?(file)
    return %w(.yml .yaml).include?(File.extname(file))
  end

  def parse(file_path)
    timesheet =
      if File.size(file_path) <= 1
        {}
      else
        YAML.load_file(file_path)
      end
    throw 'invalid line: file should contain map' unless timesheet.is_a?(Hash)
    result = []

    timesheet.each do |date, entries|
      next if entries.nil?
      throw 'invalid line: entries should be an array' unless entries.is_a?(Array)

      entries.each do |entry|
        result << parse_entry(entry, date)
      end
    end
    result
  end

  def archive(file_path, archive_path, date)
    old_timesheet = ""
    File.read(file_path).each_line do |line|
      break if line.start_with? "---"
      old_timesheet += line
    end

    FileUtils.mkdir archive_path unless File.directory? archive_path
    archive_filename = date.strftime("%Y-%m-%d") + ".yml"
    File.write("#{archive_path}/#{archive_filename}", old_timesheet)

    next_monday = (Date.today + ((1 - Date.today.wday) % 7)).strftime("%Y-%m-%d")
    File.write(file_path, "#{next_monday}:\n\n\n---\n# Letzte Woche\n" + old_timesheet)
  end

  def format(entries)
    buf = ""
    days = entries.group_by {|e| e[:date] }.to_a.sort_by { |x| x[0] }
    days.each do |date, day|
      buf << "#{date}:\n"
      day.each do |e|
        buf << "  # #{e[:comment]}\n" if e[:comment]
        buf << "  - #{qarter_time(e[:time] || 0.0)}\t#{e[:activity]}\t#{e[:redmine]}#{e[:issue]}\t#{e[:text]}\n"
      end
    end
    buf
  end

  private

  def parse_entry(entry, date)
    time, activity, issue_ref, text = entry.split(/\s+/, 4)

    if @templates.key? activity
      template = @templates[activity]
      activity = template["activity"]
      issue_ref ||= template["issue"].to_s
      text ||= template["text"]
    end

    if !issue_ref && activity =~ /^([a-z]*)(\d+)$/i
      activity, issue_ref = nil, activity
    end

    _, redmine, issue = issue_ref.match(/^([a-z]*)(\d+)$/i).to_a if issue_ref

    raise "invalid line: #{entry}" unless time and issue

    {
      time: qarter_time(parse_time(time)),
      activity: activity,
      issue: issue,
      text: text,
      date: date,
      redmine: redmine
    }
  end
end
