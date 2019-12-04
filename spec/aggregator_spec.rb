require 'date'
require 'aggregator'

RSpec.describe Aggregator, '#aggregate' do
  context 'with aggregatable entries' do
    it 'aggregates #1234' do
      entries = [
          {
              time: 1.0,
              activity: 'activity',
              issue: 1234,
              text: 'text',
              date: Date.today,
              redmine: 's'
          },
          {
              time: 1.0,
              activity: nil,
              issue: 1234,
              text: nil ,
              date: Date.today,
              redmine: 's'
          }
      ]
      aggregated_entries = Aggregator.aggregate(entries)
      expect(aggregated_entries).to_not be_empty
      expect(aggregated_entries.length).to eq(1)
      expect(aggregated_entries[0][:time]).to eq(2.0)
    end
  end

end
