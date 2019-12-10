
require_relative 'parser/yaml_timesheet'
require_relative 'parser/buch_timesheet'

# TimesheetParser selects the correct parser depending on the extension.
class TimesheetParser

  def initialize(file, templates)
    @file = file
    @parser = choose_parser(file, templates)
  end

  def parse
    @parser.parse(@file)
  end

  def archive(archive_path, date)
    @parser.archive(@file, archive_path, date)
  end

  private

  def choose_parser(file, templates)
    case File.extname(file)
    when '.yaml', '.yml'
      YamlTimesheet.new(templates)
    when '.B'
      BuchTimesheet.new(templates)
    else
      throw "Unknown file extension, cannot parse #{file}"
    end
  end
end
