require 'yaml'

class Config
  DEFAULT_CONFIG = {
    timesheet_file: 'buchungen.yml',
    archive_path: 'archive',
    templates: {},
    redmines: {},
  }.freeze

  SEARCH_PATH = [
    ENV['CWD'],
    ENV['HOME'] + '/.config/buchungsstreber',
    '/etc/buchungsstreber',
    __dir__ + '/..'
  ].freeze

  def self.load(file = nil)
    file ||= SEARCH_PATH.map { |p| File.expand_path('config.yml', p) }.find { |f| File.exist?(f) }

    return parse_config file if File.exist?(file)
    throw 'no config.yml file found'
  end

  def self.parse_config(file)
    config = YAML.load_file file
    config = config.each_with_object({}) do |e, memo|
      key, value = e[0].to_sym, e[1]
      memo[key] = value || DEFAULT_CONFIG[key]
    end
    config
  end
end
