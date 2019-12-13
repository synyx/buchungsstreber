require 'date'
require 'parser'
require 'parser/yaml_timesheet'
require 'validator'

require_relative 'timesheet_examples'

RSpec.describe YamlTimesheet, '#common' do
  templates = {
      'BeispielDaily' => {
          'activity' => 'Daily',
          'issue' => 'S99999',
          'text' => 'Daily',
      }
  }.freeze
  it_should_behave_like 'a timesheet parser', '.yml', templates
end

RSpec.describe YamlTimesheet, '#parse' do
  subject { YamlTimesheet.new({}).parse('spec/examples/aggregatable.yml') }

  it 'parses aggragatable entries' do
    entries = subject.select { |e| e[:issue] == '123' }
    expect(entries).to_not be_nil
    expect(entries.length).to eq(2)
    expect(entries[-1][:text]).to be_nil
  end
end

describe YamlTimesheet, '#archive' do
  include FakeFS::SpecHelpers

  templates = {
    'BeispielDaily' => {
      'activity' => 'Daily',
      'issue' => 'S99999',
      'text' => 'Daily',
    }
  }.freeze
  subject { YamlTimesheet.new(templates) }

  it 'archives correctly' do
    # Provide the example file in the fake filesystem
    config = File.expand_path('examples', __dir__)
    FakeFS::FileSystem.clone(config)
    timesheet_path = "#{config}/test.yml"

    subject.archive(timesheet_path, '/archive', Date.parse('2019-06-18'))

    # Read the file (options for systems with non-utf8 locale)
    text = File.read(timesheet_path, mode: 'rb', encoding: 'UTF-8')

    expect(text).to match(/# Letzte Woche/)
  end
end
