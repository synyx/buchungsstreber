class Generator
  GENERATORS = []

  def self.generate(date)
    GENERATORS.each_with_object([]) { |g,memo| memo << g.generate(date) }.flatten.compact.uniq
  end

  module Base
    # Any time a class uses the base parser module, it gets added to the list of parsers
    def self.included(klass)
      GENERATORS << klass.new
    end

  end
end
