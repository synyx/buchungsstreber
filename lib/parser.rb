
require_relative 'parser/yaml_timesheet'
require_relative 'parser/buch_timesheet'

# TimesheetParser selects the correct parser depending on the extension.
class TimesheetParser

  def initialize(templates)
    @templates = templates
  end

  def parse(file)
    case File.extname(file)
    when 'yaml'
      YamlTimesheet.new(@templates).parse(file)
    when 'buchungen'
      BuchTimesheet.new(@templates).parse(file)
    else
      throw 'Unknown file extension, cannot parse'
    end
  end
end
