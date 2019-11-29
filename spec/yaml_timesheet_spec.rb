require 'parser/yaml_timesheet'

RSpec.describe  YamlTimesheet, '#parse' do
  context 'with file' do
    it 'parses the file' do
      buchungen = YamlTimesheet.new({}).parse('example.buchungen.yml')
      expect(buchungen).to_not be_empty
    end
  end
end
