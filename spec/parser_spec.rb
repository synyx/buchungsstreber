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

  it 'raises error on unknown filetypes' do
    expect { TimesheetParser.new('../CHANGELOG.md', {}) }.to raise_error(/file extension/)
  end

end
