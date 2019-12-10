require 'parser'
require 'parser/yaml_timesheet'
require 'parser/buch_timesheet'

describe TimesheetParser do
  it 'initializes yaml parser' do
    file = '../example.buchungen.yml'
    p = TimesheetParser.new(file, {})
    expect(p).to_not be_nil
  end

  it 'initializes B parser' do
    file = 'examples/test.B'
    p = TimesheetParser.new(file, {})
    expect(p).to_not be_nil
  end

  it 'calls through to the parser for parsing' do
    expect_any_instance_of(MockParser).to receive(:parse).and_return(true)

    tp = TimesheetParser.new('mock', {})
    expect(tp.parse).to eq(true)
  end

  it 'calls through to the parser for archiving' do
    expect_any_instance_of(MockParser).to receive(:archive).and_return(true)

    tp = TimesheetParser.new('mock', {})
    expect(tp.archive('mockpath', Date.today)).to eq(true)
  end

  it 'raises error on unknown filetypes' do
    expect { TimesheetParser.new('../CHANGELOG.md', {}) }.to raise_error(/file extension/)
  end

end

class MockParser
  extend TimesheetParser::Base

  def self.parses?(x)
    x == 'mock'
  end

  def initialize(t)
  end

  def parse(f)
  end

  def archive(*a)
  end
end
