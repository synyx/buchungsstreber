require 'buchungsstreber/parser'
require 'buchungsstreber/parser/buch_timesheet'
require 'buchungsstreber/validator'

require_relative 'timesheet_examples'

RSpec.describe BuchTimesheet, '#common' do
  it_should_behave_like 'a timesheet parser', '.B'
end

RSpec.describe BuchTimesheet, '#parse' do
  subject { BuchTimesheet.new({}, 0.25).parse('spec/examples/aggregatable.B') }

  it 'parses aggragatable entries' do
    entries = subject.select { |e| e[:issue] == '123' }
    expect(entries).to_not be_nil
    expect(entries.length).to eq(2)
    expect(entries[-1][:text]).to be_nil
  end
end

RSpec.describe BuchTimesheet, '#archive' do
  let(:timesheet_path) { expand_path('~/.config/buchungsstreber/buchungen.yml') }
  let(:archive_path) { expand_path('~/.config/buchungsstreber/archive') }
  let(:example_file) { File.expand_path('examples/test.B', __dir__) }

  subject { BuchTimesheet.new({}, 0.25) }

  it 'has implemented archiving' do
    FileUtils.mkdir_p(File.dirname(timesheet_path))
    FileUtils.copy(example_file, timesheet_path)
    archive_file = "#{archive_path}/2016-07-21.B"

    subject.archive(timesheet_path, archive_path, Date.parse('2016-07-21'))

    # The archived file is identical to the current file
    expect(File.size(timesheet_path)).to eq(File.size(archive_file))

    text = File.read(archive_file)
    expect(text).to match(/2016-07-21/)
    expect(text).to match(/2016-07-22/)
  end
end
