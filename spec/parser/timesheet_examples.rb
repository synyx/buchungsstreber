require 'tempfile'

require 'buchungsstreber/parser'

RSpec.shared_examples 'a timesheet parser' do |extension, templates|
  subject { described_class.new("spec/examples/test#{extension}", templates || {}, 0.25).parse }

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
      v = subject.map { |x| Buchungsstreber::Validator.validate(x, redmine) }

      expect(v).to_not include(false)
    end

    it 'handles templates' do
      entry = subject.select {|e| e.issue.to_i == 99999 }.first
      expect(entry[:text]).to eq('Daily')
    end
  end

  context 'invalid' do
    it 'raises on invalid lines' do
      expect { described_class.new("spec/examples/invalid#{extension}", templates || {}, 0.25).parse }.to raise_exception(/invalid line/)
    end

    it 'raises on invalid times' do
      expect { described_class.new("spec/examples/invalid_time#{extension}", templates || {}, 0.25).parse }.to raise_exception(/invalid time/)
    end
  end

  context 'generating' do
    it 'can render time entries' do
      e = [{ issue: '1234', activity: 'Dev', text: 'asdf', time: 0.5, date: Date.parse('1970-01-01') }]
      expect(described_class.new('', {}, 0.25).format(e)).to include('asdf')
    end

    it 'produces something the same parser can parse' do
      e1 = [{ issue: '1234', activity: 'Dev', text: 'asdf', time: 0.5, date: Date.parse('1970-01-01') }]
      str = described_class.new('', {}, 0.25).format(e1)

      file = Tempfile.new('foo')
      begin
        file.write(str)
        file.close
        parser = described_class.new(file.path, templates || {}, 0.25)
        e2 = parser.parse
        e1[0].each do |k, v|
          expect(e2[0][k]).to eq(v)
        end
      ensure
        file.unlink
      end
    end
  end
end
