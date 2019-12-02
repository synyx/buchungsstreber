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
