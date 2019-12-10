require 'yaml'

class Config
  DEFAULT_CONFIG = {
    timesheet_file: 'buchungen.yml',
    archive_path: 'archive',
    templates: {},
    hours: 8
  }.freeze

  SEARCH_PATH = [
    ENV['CWD'],
    ENV['HOME'] + '/.config/buchungsstreber',
    '/etc/buchungsstreber',
    __dir__ + '/..'
  ].freeze

  def self.load(file = nil)
    # Find the first file named `config.yml` in SEARCH_PATH if not given
    file ||= SEARCH_PATH.map { |p| File.expand_path('config.yml', p) }.find { |f| File.exist?(f) }

    return parse_config file if File.exist?(file)
    throw 'no config.yml file found'
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
