class Generator
  GENERATORS = []

  def initialize(config)
    @config = config
  end

  def generate(date)
    GENERATORS.each_with_object([]) do |g,memo|
      config = @config[g.name.split(':').last.downcase]
      generator = g.new(config)
      memo << generator.generate(date)
    end.flatten.compact.uniq do |e|
      [e[:issue], e[:date], e[:comment], e[:text], e[:time], e[:activity], e[:redmine]].map(&:to_s).map(&:downcase).join
    end
  end

  module Base
    # Any time a class uses the base module, it gets added to the list
    def self.included(klass)
      GENERATORS << klass
    end

  end
end