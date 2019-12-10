require 'parser'

describe TimesheetParser do
  it 'initializes yaml parser' do
    p = TimesheetParser.new('../example.buchungen.yml', {})
    expect(p).to_not be_nil
  end

  it 'initializes B parser' do
    p = TimesheetParser.new('examples/test.B', {})
    expect(p).to_not be_nil
  end

  it 'raises error on unknown filetypes' do
    expect { TimesheetParser.new('../CHANGELOG.md', {}) }.to raise_error(/file extension/)
  end

end
