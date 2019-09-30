require "yaml"
require "date"
require "time"

class YamlTimesheet

  def initialize(templates)
    @templates = templates
  end

  def parse(file_path)
    timesheet = YAML.load_file(file_path)
    result = []

    timesheet.each do |date, entries|
      next if entries.nil?
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

  private

  def parse_entry(entry, date)
    time, activity, issue_ref, text = entry.split(/\s+/, 4)

    if @templates.key? activity
      template = @templates[activity]
      activity = template["activity"]
      issue_ref ||= template["issue"].to_s
      text ||= template["text"]
    end

    _, redmine, issue = issue_ref.match(/^([a-z]*)(\d+)$/i).to_a if issue_ref

    if time.include? "-"
      time = parse_time_diff(time)
    end

    {
      time: time.to_f,
      activity: activity,
      issue: issue,
      text: text,
      date: date,
      redmine: redmine
    }
  end

  def parse_time_diff(time_diff)
    start, done = time_diff.split "-"
    diff_in_s = (Time.parse(done) - Time.parse(start)).to_f
    quarter_hours = (diff_in_s / 900).ceil

    quarter_hours * 0.25
  end
end
