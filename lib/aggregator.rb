class Aggregator

  def self.aggregate(entries)

    aggregated_entries = []
    entries.each do |entry|
      if entry[:text]
        aggregated_entries << entry
      else
        possible_aggregations = aggregated_entries.select { |aggregated_entry| aggregatable?(aggregated_entry, entry) }
        unless possible_aggregations.empty?
          possible_aggregations[-1][:time] += entry[:time]
        end
      end
    end

    return aggregated_entries
  end

  private

  def self.aggregatable?(entry, extension)
    return entry[:redmine] == extension[:redmine] &&
        entry[:issue] == extension[:issue] &&
        entry[:date] == extension[:date] &&
        (entry[:activity] == extension[:activity] || !extension[:activity])
  end

end
