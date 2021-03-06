require 'date'

require 'buchungsstreber/parser'
require 'buchungsstreber/parser/yaml_timesheet'
require 'buchungsstreber/validator'

require_relative 'timesheet_examples'

RSpec.describe Buchungsstreber::YamlTimesheet do
  templates = {
      'BeispielDaily' => {
          'activity' => 'Daily',
          'issue' => 'S99999',
          'text' => 'Daily',
      }
  }.freeze
  it_should_behave_like 'a timesheet parser', '.yml', templates
end

RSpec.describe Buchungsstreber::YamlTimesheet, '#parse' do
  subject { described_class.new({}, 0.25).parse('spec/examples/aggregatable.yml') }

  it 'parses aggragatable entries' do
    entries = subject.select { |e| e[:issue] == '123' }
    expect(entries).to_not be_nil
    expect(entries.length).to eq(2)
    expect(entries[-1][:text]).to be_nil
  end
end

RSpec.describe Buchungsstreber::YamlTimesheet, '#archive', type: :aruba do
  let(:timesheet_path) { expand_path('~/.config/buchungsstreber/buchungen.yml') }
  let(:archive_path) { expand_path('~/.config/buchungsstreber/archive') }
  let(:example_file) { File.expand_path('../../example.buchungen.yml', __dir__) }

  templates = {
    'BeispielDaily' => {
      'activity' => 'Daily',
      'issue' => 'S99999',
      'text' => 'Daily',
    }
  }.freeze
  subject { described_class.new(templates, 0.25) }

  it 'archives correctly' do
    FileUtils.mkdir_p(File.dirname(timesheet_path))
    FileUtils.copy(example_file, timesheet_path)

    subject.archive(timesheet_path, archive_path, Date.parse('2019-06-18'))

    # Read the file (options for systems with non-utf8 locale)
    text = File.read(timesheet_path, mode: 'rb', encoding: 'UTF-8')

    expect(text).to match(/# Letzte Woche/)
  end
end
