
require_relative 'parser/yaml_timesheet'
require_relative 'parser/buch_timesheet'

# TimesheetParser selects the correct parser depending on the extension.
class TimesheetParser

  def initialize(file, templates)
    @file = file
    @parser = choose_parser(file).new(templates)
  end

  def parse
    @parser.parse(@file)
  end

  def archive(archive_path, date)
    @parser.archive(@file, archive_path, date)
  end

  private

  def choose_parser(file)
    case File.extname(file)
    when '.yaml', '.yml'
      YamlTimesheet
    when '.B'
      BuchTimesheet
    else
      throw "Unknown file extension, cannot parse #{file}"
    end
  end
end
