class Buchungsstreber::Resolver

  def initialize(config)
    @config = config
    @resolvers = []
  end

  def resolve(entry)
    previous_entry = entry.dup
    iteration = 0
    loop do
      @resolvers.each do |r|
        resolver(r).resolve(entry)
      end

      break if entry == previous_entry

      throw 'Resolving took too many iterations' unless iteration < 100

      previous_entry = entry.dup
      iteration += 1
    end
    entry
  end

  def load!(name)
    resolver = Base.resolver(name)
    @resolvers << resolver if resolver
  end

  private

  def resolver(klass)
    config = @config[:resolvers][klass.name.split(':').last.downcase]
    config ||= @config[klass.name.split(':').last.downcase.to_sym] # toplevel config
    klass.new(config)
  end

  module Base
    # Any time a class uses the base parser module, it gets added to the list of parsers
    def self.included(klass)
      @resolvers ||= []
      @resolvers << klass
    end

    def self.resolver(name)
      @resolvers.find { |g| g.name.split('::').last.downcase == name }
    end
  end
end
