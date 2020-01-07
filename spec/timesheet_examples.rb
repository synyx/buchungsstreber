require 'parser'

RSpec.shared_examples 'a timesheet parser' do |extension, templates|
  subject { described_class.new(templates || {}).parse("spec/examples/test#{extension}") }

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


  context 'invalid' do
    it 'raises on invalid lines' do
      expect { described_class.new(templates || {}).parse("spec/examples/invalid#{extension}") }.to raise_exception(/invalid line/)
    end

    it 'raises on invalid times' do
      expect { described_class.new(templates || {}).parse("spec/examples/invalid_time#{extension}") }.to raise_exception(/invalid time/)
    end
  end
end
