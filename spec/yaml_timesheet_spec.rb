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
