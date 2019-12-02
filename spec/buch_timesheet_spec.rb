require 'parser/buch_timesheet'
require 'validator'

RSpec.describe BuchTimesheet, '#parse' do
  subject { BuchTimesheet.new([]).parse('spec/examples/test.B') }

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
      expect(subject[0][:time]).to eq(1.5)
    end

    it 'parses colon times correctly' do
      expect(subject[6][:time]).to eq(1.25)
    end

    it 'makes for a valid timesheet' do
      v = subject.map { |x| Validator.new.validate(x, redmine) }

      expect(v).to_not include(false)
    end
  end

  context 'invalid' do
    it 'raises on invalid lines' do
      expect { BuchTimesheet.new([]).parse('spec/examples/invalid.B') }.to raise_exception(/invalid/)
    end

    it 'raises on invalid times' do
      expect { BuchTimesheet.new([]).parse('spec/examples/invalid_time.B') }.to raise_exception(/invalid/)
    end
  end
end
