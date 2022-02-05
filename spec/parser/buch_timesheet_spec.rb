require 'buchungsstreber/parser'
require 'buchungsstreber/parser/buch_timesheet'
require 'buchungsstreber/validator'

require_relative 'timesheet_examples'

RSpec.describe Buchungsstreber::BuchTimesheet, '#common' do
  templates = {
    'BeispielDaily' => {
      'activity' => 'Daily',
      'issue' => 's#99999',
      'text' => 'Daily',
    }
  }.freeze
  it_should_behave_like 'a timesheet parser', '.B', templates
end

RSpec.describe Buchungsstreber::BuchTimesheet, '#parse' do
  subject { described_class.new('spec/examples/aggregatable.B', {}, 0.25).parse }

  it 'parses aggragatable entries' do
    entries = subject.select { |e| e[:issue] == '123' }
    expect(entries).to_not be_nil
    expect(entries.length).to eq(2)
    expect(entries[-1][:text]).to be_nil
  end
end

RSpec.describe Buchungsstreber::BuchTimesheet, '#archive' do
  let(:timesheet_path) do
    p = expand_path('~/.config/buchungsstreber/buchungen.yml')
    FileUtils.mkdir_p(File.dirname(p))
    FileUtils.copy(example_file, p)
    p
  end
  let(:archive_path) { expand_path('~/.config/buchungsstreber/archive') }
  let(:example_file) { File.expand_path('../examples/test.B', __dir__) }

  subject { described_class.new(timesheet_path, {}, 0.25) }

  it 'has implemented archiving' do
    archive_file = "#{archive_path}/2016-07-21.B"

    subject.archive(archive_path, Date.parse('2016-07-21'))

    # The archived file is identical to the current file
    expect(File.size(timesheet_path)).to eq(File.size(archive_file))

    text = File.read(archive_file)
    expect(text).to match(/2016-07-21/)
    expect(text).to match(/2016-07-22/)
  end
end
