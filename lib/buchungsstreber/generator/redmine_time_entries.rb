class Buchungsstreber::Generator::RedmineTimeEntries
  include Buchungsstreber::Generator::Base

  def initialize(config)
    @redmines = Redmines.new(@config[:redmines])
  end

  def generate(date)
    @redmines.map do |r|
      r.get_times(date).each do |entry|
        entry[:redmine] = r.prefix unless @redmines.default?(r.prefix)
      end
    end.flatten
  end
end
