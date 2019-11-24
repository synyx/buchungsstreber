require 'parser/buch_timesheet'

RSpec.describe  BuchTimesheet, '#parse' do
  context 'with file' do
    it 'parses the file' do
      BuchTimesheet.new([]).parse('spec/examples/test.buchungen')
    end
  end
end