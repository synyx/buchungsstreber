class Aggregator

  def self.aggregate(entries)

    aggregated_entries = []
    entries.each do |entry|
      possible_aggregations = aggregated_entries.select { |aggregated_entry| aggregatable?(aggregated_entry, entry) }
      if possible_aggregations.empty?
        aggregated_entries << entry.dup
      else
        possible_aggregations[-1][:time] += entry[:time]
      end
    end

    return aggregated_entries
  end

  private

  def self.aggregatable?(entry, extension)
    return entry[:redmine] == extension[:redmine] &&
        entry[:issue] == extension[:issue] &&
        entry[:date] == extension[:date] &&
        (entry[:text] == extension[:text] || !extension[:text]) &&
        (entry[:activity] == extension[:activity] || !extension[:activity])
  end

end
