require 'parser/buch_timesheet'

RSpec.describe BuchTimesheet, '#parse' do
  context 'with file' do
    it 'parses the file' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.buchungen')
      expect(r).to_not be_empty
    end

    it 'parses comma times correctly' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.buchungen')
      expect(r[0][:time]).to eq(1.5)
    end

    it 'parses colon times correctly' do
      r = BuchTimesheet.new([]).parse('spec/examples/test.buchungen')
      expect(r[6][:time]).to eq(1.25)
    end
  end
end
