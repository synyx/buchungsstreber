require 'date'
require 'validator'

describe Validator do
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

  it 'succeeds' do
    entry = default_entry
    r = subject.validate(entry, redmine)
    expect(r).to be(true)
  end

  it 'fails on missing time' do
    entry = default_entry.merge(time: nil)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on negative time' do
    entry = default_entry.merge(time: -1)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on zero time' do
    entry = default_entry.merge(time: 0)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on too much hours' do
    entry = default_entry.merge(time: 17)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails when time is not dividable by 4' do
    entry = default_entry.merge(time: 0.60)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on missing date' do
    entry = default_entry.merge(date: nil)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on date too far in the future' do
    entry = default_entry.merge(date: Date.today + 1)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  it 'fails on missing activity' do
    entry = default_entry.merge(activity: nil)
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  xit 'fails on invalid activity' do
    entry = default_entry.merge(activity: 'blahflubbls')
    r = subject.validate(entry, redmine)
    expect(r).to be(false)
  end

  context 'issue' do
    it 'fails on missing issue' do
      entry = default_entry.merge(issue: nil)
      r = subject.validate(entry, redmine)
      expect(r).to be(false)
    end

    it 'fails on negative issue' do
      entry = default_entry.merge(issue: -1)
      r = subject.validate(entry, redmine)
      expect(r).to be(false)
    end
  end

  context 'text' do
    it 'fails on missing text' do
      entry = default_entry.merge(text: nil)
      r = subject.validate(entry, redmine)
      expect(r).to be(false)
    end

    it 'fails on not enough text' do
      entry = default_entry.merge(text: '')
      r = subject.validate(entry, redmine)
      expect(r).to be(false)
    end
  end
end
