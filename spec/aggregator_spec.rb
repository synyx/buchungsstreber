require 'date'
require 'aggregator'

RSpec.describe Aggregator, '#aggregate' do
  normal_entry = {
      time: 1.0,
      activity: 'activity',
      issue: 1234,
      text: 'text',
      date: Date.today,
      redmine: 's'
  }.freeze
  aggregatable_entry = {
      time: 1.0,
      activity: nil,
      issue: 1234,
      text: nil,
      date: Date.today,
      redmine: 's'
  }.freeze
  other_entry = {
      time: 1.0,
      activity: nil,
      issue: 5432,
      text: nil,
      date: Date.today,
      redmine: 's'
  }.freeze

  context 'with aggregatable entries' do
    it 'aggregates #1234' do
      entries = [normal_entry, aggregatable_entry]
      aggregated_entries = Aggregator.aggregate(entries)
      expect(aggregated_entries).to_not be_empty
      expect(aggregated_entries.length).to eq(1)
      expect(aggregated_entries[0][:time]).to eq(2.0)
    end

    it 'aggregates #1234 when another entry separates the aggregatables' do
      entries = [normal_entry, other_entry, aggregatable_entry]
      aggregated_entries = Aggregator.aggregate(entries)
      expect(aggregated_entries).to_not be_empty
      expect(aggregated_entries.length).to eq(2)
      expect(aggregated_entries[0][:time]).to eq(2.0)
    end
  end

end
