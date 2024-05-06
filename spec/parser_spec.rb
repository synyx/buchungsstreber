require 'buchungsstreber/parser'
require 'buchungsstreber/parser/yaml_timesheet'
require 'buchungsstreber/parser/buch_timesheet'

RSpec.describe Buchungsstreber::TimesheetParser do
  it 'initializes yaml parser' do
    file = '../example.buchungen.yml'
    minimum_time = 0.25
    p = described_class.new(file, {}, minimum_time)
    expect(p).to_not be_nil
  end

  it 'initializes B parser' do
    file = 'examples/test.B'
    minimum_time = 0.25
    p = described_class.new(file, {}, minimum_time)
    expect(p).to_not be_nil
  end

  it 'calls through to the parser for parsing' do
    minimum_time = 0.25
    expect_any_instance_of(MockParser).to receive(:parse).and_return(true)

    tp = described_class.new('mock', {}, minimum_time)
    expect(tp.parse).to eq(true)
  end

  it 'calls through to the parser for archiving' do
    minimum_time = 0.25
    expect_any_instance_of(MockParser).to receive(:archive).and_return(true)

    tp = described_class.new('mock', {}, minimum_time)
    expect(tp.archive('mockpath', Date.today)).to eq(true)
  end

  it 'raises error on unknown filetypes' do
    minimum_time = 0.25
    expect { described_class.new('../CHANGELOG.md', {}, minimum_time) }.to raise_error(/file extension/)
  end

  context 'minimum_time' do
    subject {
      Object.new.extend(Buchungsstreber::TimesheetParser::Base)
    }
    it 'rounds up to the minimum time interval' do
      minimum_time = 0.5
      expect(subject.minimum_time(0.75, minimum_time)).to eq(1.0)
    end
    it 'does not change full intervals' do
      minimum_time = 0.5
      expect(subject.minimum_time(1.5, minimum_time)).to eq(1.5)
    end
    it 'handles weird minimal time intervals' do
      minimum_time = 0.123
      expect(subject.minimum_time(0.1, minimum_time)).to eq(0.123)
    end
  end
end

class MockParser
  include Buchungsstreber::TimesheetParser::Base

  def self.parses?(file)
    file == 'mock'
  end

  def initialize(file, template, minimum_time); end

  def parse; end

  def archive(archive_path, date); end
end
