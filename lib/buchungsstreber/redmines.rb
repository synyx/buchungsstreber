class Redmines
  def initialize(redmines)
    @redmines = {}
    redmines.each do |config|
      redmine = RedmineApi.new(config)
      @redmines[config["prefix"]] = redmine
      @default = redmine if config["default"]
    end
  end

  def get(prefix)
    case
    when prefix.nil? || prefix == ''
      @default
    when !@redmines.key?(prefix)
      throw "unknown redmine prefix #{prefix}"
    else
      @redmines[prefix]
    end
  end

  def default?(prefix)
    get(prefix) == @default
  end
end
