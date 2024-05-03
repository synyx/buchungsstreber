# TimesheetParser selects the correct parser depending on the extension.
class Buchungsstreber::TimesheetParser
  PARSERS = []

  def initialize(file, templates, minimum_time)
    @file = file
    @minimum_time = minimum_time
    @parser = choose_parser(file).new(file, templates, minimum_time)
  end

  def parse
    @parser.parse
  end

  def add(entries)
    old_content = File.read(@file) rescue ''
    new_content = @parser.add(entries)

    if new_content.length < old_content.length
      warn "Rejecting new content due to safety concerns, smaller than before"
      return
    end

    # Backup file to reduce problems...
    FileUtils.cp(@file, "#{@file}~")

    # Fill file with new content
    File.open(@file, 'w+') do |file|
      file.write(new_content)
    end
  end

  def archive(archive_path, date)
    @parser.archive(archive_path, date)
  end

  def format(entries)
    @parser.format(entries)
  end

  def parse_entry(entry, date)
    @parser.parse_entry(entry, date)
  end

  private

  def choose_parser(file)
    parser = PARSERS.find { |p| p.respond_to?(:parses?) and p.parses?(file) }
    parser or throw "Unknown file extension, cannot parse #{file}"
  end

  module Base
    # Any time a class uses the base parser module, it gets added to the list of parsers
    def self.included(klass)
      PARSERS << klass
    end

    # @return [Float] time in hours
    def parse_time(time_descr)
      case time_descr
      when /-/
        parse_time_diff(time_descr)
      when /^(\d+):(\d+)$/
        hours = $1.to_i
        minutes = $2.to_i
        hours + minutes / 60.0
      when /^\d+(?:\.\d+)?$/
        time_descr.to_f
      else
        raise "invalid time: #{time_descr}"
      end
    end

    def minimum_time(time, minimum_time_value)
      time_intervals = (time / minimum_time_value).ceil

      time_intervals * minimum_time_value
    end

    private

    def parse_time_diff(time_diff)
      start, done = time_diff.split "-"
      diff_in_s = (Time.parse(done) - Time.parse(start)).to_f
      diff_in_s.to_f / 60 / 60
    end
  end
end
