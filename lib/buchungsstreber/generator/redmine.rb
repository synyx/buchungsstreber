class Generator::Redmine
  include Generator::Base

  RE = /\s*(?<project>.*) - (?<tracker>.*) #(?<issue>\d+)(?: \((?<state>[^:]+)\))?: (?<title>.*)/

  def initialize(config)
    @config = config
  end

  def generate(date)
    @config.map do |rm|
      `cmr "#{rm[:url]}" #{rm[:uid]} "#{rm[:rsskey]}" "#{date}"`.lines.map do |line|
        if line =~ RE
          {
            issue: $~[:issue],
            comment: $~[:project] + ' ' + $~[:title],
            date: date,
            redmine: rm[:redmine],
          }
        end
      end
    end
  end
end
