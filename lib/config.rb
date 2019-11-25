class Config
  def self.load
    [__dir__, ENV['HOME'] + '/.config/buchungsstreber', '/etc/buchungsstreber'].each do |path|
      f = File.expand_path('./config.yml', path)
      if File.exist?(f)
        return YAML.load_file f
      end
    end
    throw 'no config.yml file found'
  end
end
