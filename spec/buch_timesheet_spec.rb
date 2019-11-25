require 'parser/buch_timesheet'
require 'validator'
require 'mock_redmine'

RSpec.describe BuchTimesheet, '#parse' do
  context 'with file' do
    it 'parses the file' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.B')
      expect(r).to_not be_empty
    end

    it 'parses comma times correctly' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.B')
      expect(r[0][:time]).to eq(1.5)
    end

    it 'parses colon times correctly' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.B')
      expect(r[6][:time]).to eq(1.25)
    end

    it 'makes for a valid timesheet' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.B')
      v = r.map {|x| Validator.new.validate(x, MockRedmine.new) }
      expect(v).to_not include(false)
    end
  end
end
