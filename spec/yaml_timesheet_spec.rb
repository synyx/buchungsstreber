require 'date'
require 'parser/yaml_timesheet'
require 'validator'

describe YamlTimesheet do
  TEMPLATES = {
      'BeispielDaily' => {
        'activity' => 'Daily',
        'issue' => 'S99999',
        'text' => 'Daily',
      }
  }.freeze
  subject { YamlTimesheet.new(TEMPLATES).parse('example.buchungen.yml') }

  let(:redmine) do
    redmine = double("redmine")
    allow(redmine).to receive(:valid_activity?).and_return(true)
    redmine
  end

  context 'with example file' do
    it 'parses the file' do
      expect(subject).to_not be_empty
    end

    it 'parses comma times correctly' do
      expect(subject[0][:time]).to eq(0.25)
    end

    it 'parses colon times correctly' do
      expect(subject[3][:time]).to eq(0.75)
    end

    it 'makes for a valid timesheet' do
      v = subject.map { |x| Validator.new.validate(x, redmine) }

      expect(v).to_not include(false)
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
