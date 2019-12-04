require 'date'
require 'parser/yaml_timesheet'

RSpec.describe  YamlTimesheet, '#parse' do
  context 'with file' do
    it 'parses the file' do
      buchungen = YamlTimesheet.new({}).parse('example.buchungen.yml')
      expect(buchungen).to_not be_empty
    end
  end
end

describe YamlTimesheet, '#archive' do
  include FakeFS::SpecHelpers

  TEMPLATES = {
    'BeispielDaily' => {
      'activity' => 'Daily',
      'issue' => 'S99999',
      'text' => 'Daily',
    }
  }.freeze
  subject { YamlTimesheet.new(TEMPLATES) }

  it 'archives correctly' do
    # Provide the example file in the fake filesystem
    config = File.expand_path('..', __dir__)
    FakeFS::FileSystem.clone(config)
    timesheet_path = "#{config}/example.buchungen.yml"

    subject.archive(timesheet_path, '/archive', Date.parse('2019-06-18'))

    # Read the file (options for systems with non-utf8 locale)
    text = File.read(timesheet_path, mode: 'rb', encoding: 'UTF-8')

    expect(text).to match(/# Letzte Woche/)
  end
end
