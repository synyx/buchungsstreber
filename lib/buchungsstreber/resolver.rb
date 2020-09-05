class Resolver
  RESOLVERS = []

  def initialize(config)
    @config = config
    @resolvers = {}
  end

  def resolve(entry)
    RESOLVERS.each do |r|
      resolver(r).resolve(entry)
    end
    # TODO: it would be better to keep track of changes to stop resolving
    RESOLVERS.each do |r|
      resolver(r).resolve(entry)
    end
    entry
  end

  private

  def resolver(klass)
    config = @config[:resolvers][klass.name.split(':').last.downcase]
    config ||= @config[klass.name.split(':').last.downcase.to_sym] # toplevel config
    @resolvers[klass] ||= klass.new(config)
  end

  module Base
    # Any time a class uses the base parser module, it gets added to the list of parsers
    def self.included(klass)
      RESOLVERS << klass
    end
  end
end
