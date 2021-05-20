class Buchungsstreber::Redmines
  include Enumerable

  def initialize(redmines)
    @redmines = {}
    redmines.each do |config|
      redmine = Buchungsstreber::RedmineApi.new(config)
      @redmines[config["prefix"]] = redmine
      @default = redmine if config["default"]
    end
  end

  def get(prefix)
    if prefix.nil? || prefix == ''
      @default
    elsif !@redmines.key?(prefix)
      throw "unknown redmine prefix #{prefix}"
    else
      @redmines[prefix]
    end
  end

  def default?(prefix)
    get(prefix) == @default
  end

  def each(&block)
    @redmines.each do |prefix, redmine|
      block.call(redmine)
    end
  end
end
