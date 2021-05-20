class Buchungsstreber::Generator
  attr_reader :generators

  def initialize(config)
    @config = config
    @generators = []
  end

  def generate(date)
    generators.each_with_object([]) do |g, memo|
      config = @config[g.name.split(':').last.downcase]
      generator = g.new(config)
      memo << generator.generate(date)
    end.flatten.compact.uniq do |e|
      [e[:issue], e[:date], e[:comment], e[:text], e[:time], e[:activity], e[:redmine]].map(&:to_s).map(&:downcase).join
    end
  end

  def load!(generator_name)
    generator = Base.generator(generator_name)
    @generators << generator if generator
  end

  module Base
    # Any time a class uses the base module, it gets added to the list
    def self.included(klass)
      @generators ||= []
      @generators << klass
    end

    def self.generator(name)
      @generators.find { |g| g.name.split('::').last.downcase == name }
    end
  end
end
