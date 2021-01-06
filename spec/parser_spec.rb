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
end

class MockParser
  include Buchungsstreber::TimesheetParser::Base

  def self.parses?(file)
    file == 'mock'
  end

  def initialize(template, minimum_time); end

  def parse(file); end

  def archive(file_path, archive_path, date); end
end
