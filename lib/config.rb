class Config
  def self.load
    [__dir__, ENV['HOME'] + '/.config/buchungsstreber', '/etc/buchungsstreber'].each do |path|
      f = File.expand_path('./config.yml', path)
      if File.exist?(f)
        YAML.load_file File.expand_path('./config.yml', __dir__)
      end
    end
  end
end
