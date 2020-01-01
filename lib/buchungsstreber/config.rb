require 'yaml'

class Config
  DEFAULT_CONFIG = {
    timesheet_file: 'buchungen.yml',
    archive_path: 'archive',
    templates: {},
    hours: 8,
    generators: {},
    resolvers: {},
  }.freeze

  DEFAULT_NAME = 'config.yml'

  def self.load(file = nil)
    # Find the first file named `config.yml` in SEARCH_PATH if not given
    file ||= find_config

    throw 'Configuration file not found.' unless file and File.exist?(file)

    parse_config file
  end

  def self.find_config
    search_path.map { |p| File.expand_path(DEFAULT_NAME, p) }.find { |f| File.exist?(f) }
  end

  def self.user_config_path
    ENV['HOME'] + '/.config/buchungsstreber'
  end

  private

  def self.search_path
    [
      ENV['CWD'],
      user_config_path,
      '/etc/buchungsstreber',
      __dir__ + '/..'
    ].freeze
  end

  def self.parse_config(file)
    config = YAML.load_file file
    config = config.each_with_object(DEFAULT_CONFIG.dup) do |e, memo|
      key, value = e[0].to_sym, e[1]
      memo[key] = value
    end
    config
  end
end
