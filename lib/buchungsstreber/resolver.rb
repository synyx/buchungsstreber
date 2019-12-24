class Resolver
  RESOLVERS = []

  def self.resolve(entry)
    RESOLVERS.map { |r| r.new }.inject(entry) { |e,r| r.resolve(e) }
  end

  module Base
    # Any time a class uses the base parser module, it gets added to the list of parsers
    def self.included(klass)
      RESOLVERS << klass
    end

  end
end
