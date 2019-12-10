require 'yaml'

class Config
  DEFAULT_CONFIG = {
    timesheet_file: 'buchungen.yml',
    archive_path: 'archive',
    templates: {},
    hours: 8
  }.freeze

  DEFAULT_NAME = 'config.yml'
  USER_CONFIG_PATH = ENV['HOME'] + '/.config/buchungsstreber'
  SEARCH_PATH = [
    ENV['CWD'],
    USER_CONFIG_PATH,
    '/etc/buchungsstreber',
    __dir__ + '/..'
  ].freeze

  def self.load(file = nil)
    # Find the first file named `config.yml` in SEARCH_PATH if not given
    file ||= find_config

    throw 'Configuration file not found.' unless file and File.exist?(file)

    parse_config file
  end

  def self.find_config
    SEARCH_PATH.map { |p| File.expand_path(DEFAULT_NAME, p) }.find { |f| File.exist?(f) }
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
