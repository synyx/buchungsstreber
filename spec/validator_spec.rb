require 'date'
require 'buchungsstreber/validator'

RSpec.describe Buchungsstreber::Validator do

  let(:default_entry) do
    {
      time: 1,
      activity: 'foo',
      issue: '1234',
      text: 'test',
      date: Date.today,
      redmine: 's'
    }.freeze
  end
  let(:redmine) do
    redmine = double("redmine")
    allow(redmine).to receive(:valid_activity?).and_return(true)
    redmine
  end

  it 'succeeds on valid entry' do
    entry = default_entry
    r = described_class.validate(entry, redmine)
    expect(r).to be(true)
  end

  context 'time' do
    it 'fails on missing time' do
      entry = default_entry.merge(time: nil)
      expect { described_class.validate(entry, redmine) }.to fail_with('missing time')
    end

    it 'fails on negative time' do
      entry = default_entry.merge(time: -1)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid time')
    end

    it 'fails on zero time' do
      entry = default_entry.merge(time: 0)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid time')
    end

    it 'fails on too much hours' do
      entry = default_entry.merge(time: 17)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid time')
    end

    it 'fails when time is not dividable by 4' do
      entry = default_entry.merge(time: 0.60)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid time')
    end
  end

  context 'date' do
    it 'fails on missing date' do
      entry = default_entry.merge(date: nil)
      expect { described_class.validate(entry, redmine) }.to fail_with('missing date')
    end

    it 'fails on date too far in the future' do
      entry = default_entry.merge(date: Date.today + 1)
      expect { described_class.validate(entry, redmine) }.to fail_with('has date from the future')
    end
  end

  context 'issue' do
    it 'fails on missing activity' do
      entry = default_entry.merge(activity: nil)
      expect { described_class.validate(entry, redmine) }.to fail_with('missing activity')
    end
  end

  context 'issue' do
    it 'fails on missing issue' do
      entry = default_entry.merge(issue: nil)
      expect { described_class.validate(entry, redmine) }.to fail_with('missing issue')
    end

    it 'fails on negative issue' do
      entry = default_entry.merge(issue: -1)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid issue')
    end
  end

  context 'text' do
    it 'fails on missing text' do
      entry = default_entry.merge(text: nil)
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid text')
    end

    it 'fails on not enough text' do
      entry = default_entry.merge(text: '')
      expect { described_class.validate(entry, redmine) }.to fail_with('invalid text')
    end

    it 'fail on missing text when allow_empty_text is false' do
      entry = default_entry.merge(text: nil)
      config = { allow_empty_text: false }
      r = described_class.validate(entry, redmine, config)
      expect(r).to be(false)
    end

    it 'succeeds on missing text when allow_empty_text is true' do
      entry = default_entry.merge(text: nil)
      config = { allow_empty_text: true }
      r = described_class.validate(entry, redmine, config)
      expect(r).to be(true)
    end

    it 'succeeds on empty text when allow_empty_text is true' do
      entry = default_entry.merge(text: '')
      config = { allow_empty_text: true }
      r = described_class.validate(entry, redmine, config)
      expect(r).to be(true)
    end
  end
end

RSpec.describe Buchungsstreber::Validator do

  let(:default_entry) do
    {
      time: 1,
      activity: 'foo',
      issue: '1234',
      text: 'test',
      date: Date.today,
      redmine: 's'
    }.freeze
  end
  let(:redmine) do
    redmine = double("redmine")
    allow(redmine).to receive(:valid_activity?).and_return(false)
    redmine
  end

  it 'fails on invalid activity' do
    expect { described_class.validate(default_entry, redmine) }.to fail_with('invalid activity')
  end
end

RSpec.describe Buchungsstreber::Validator, '#status!' do

  let(:default_entry) do
    {
      time: 1,
      activity: 'foo',
      issue: '1234',
      text: 'test',
      date: Date.today,
      redmine: 's'
    }.freeze
  end
  let(:redmine) do
    redmine = double("redmine")
    allow(redmine).to receive(:valid_activity?).and_return(false)
    allow(redmine).to receive(:same_activity?).and_return(true)
    allow(redmine).to receive(:prefix).and_return('z')
    redmine
  end

  it 'recognizes existing entries' do
    expect(redmine).to receive(:get_times).with(Date.today).and_return([default_entry])
    status = described_class.status!(default_entry.dup, redmine)
    expect(status).to contain_exactly(:existing)
  end

  it 'recognizes entries with different time' do
    other = default_entry.merge(time: 1.5)
    expect(redmine).to receive(:get_times).with(Date.today).and_return([other])
    status = described_class.status!(default_entry.dup, redmine)
    expect(status).to contain_exactly(:time_different)
  end

  it 'recognizes entries with different activity' do
    expect(redmine).to receive(:same_activity?).and_return(false)
    expect(redmine).to receive(:get_times).with(Date.today).and_return([default_entry])
    status = described_class.status!(default_entry.dup, redmine)
    expect(status).to contain_exactly(:activity_different)
  end

  it 'recognizes entries with different text' do
    other = default_entry.merge(text: 'different')
    expect(redmine).to receive(:get_times).with(Date.today).and_return([other])
    status = described_class.status!(default_entry.dup, redmine)
    expect(status).to be_empty
  end

  it 'recoginzes entry as missing if redmine found nothing' do
    expect(redmine).to receive(:get_times).with(Date.today).and_return([])
    status = described_class.status!(default_entry.dup, redmine)
    expect(status).to contain_exactly(:missing)
  end
end
