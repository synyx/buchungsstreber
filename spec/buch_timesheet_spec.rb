require 'parser'
require 'parser/buch_timesheet'
require 'validator'

require_relative 'timesheet_examples'


RSpec.describe BuchTimesheet, '#common' do
  it_should_behave_like 'a timesheet parser', '.B'
end

RSpec.describe BuchTimesheet, '#parse' do
  include FakeFS::SpecHelpers

  subject { BuchTimesheet.new([]) }

  it 'has not implemented archiving' do
    expect { subject.archive('file', '/archive', Date.today) }.to raise_exception(/not impl/)
  end
end
