require 'buchungsstreber/parser'
require 'buchungsstreber/parser/buch_timesheet'
require 'buchungsstreber/validator'

require_relative 'timesheet_examples'

RSpec.describe BuchTimesheet, '#common' do
  it_should_behave_like 'a timesheet parser', '.B'
end

RSpec.describe BuchTimesheet, '#parse' do
  subject { BuchTimesheet.new({}).parse('spec/examples/aggregatable.B') }

  it 'parses aggragatable entries' do
    entries = subject.select { |e| e[:issue] == '123' }
    expect(entries).to_not be_nil
    expect(entries.length).to eq(2)
    expect(entries[-1][:text]).to be_nil
  end
end

RSpec.describe BuchTimesheet, '#archive' do
  subject { BuchTimesheet.new({}) }

  it 'has not implemented archiving' do
    expect { subject.archive('file', '/archive', Date.today) }.to raise_exception(/not impl/)
  end
end
