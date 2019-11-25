
require_relative 'parser/yaml_timesheet'
require_relative 'parser/buch_timesheet'

# TimesheetParser selects the correct parser depending on the extension.
class TimesheetParser

  def initialize(templates)
    @templates = templates
  end

  def parse(file)
    case File.extname(file)
    when '.yaml', '.yml'
      YamlTimesheet.new(@templates).parse(file)
    when '.B'
      BuchTimesheet.new(@templates).parse(file)
    else
      throw "Unknown file extension, cannot parse #{file}"
    end
  end
end
