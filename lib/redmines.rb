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
    @redmines[prefix] || @default
  end
end
