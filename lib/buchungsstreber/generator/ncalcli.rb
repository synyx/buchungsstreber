class Generator::NCalCLI
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    if @config.empty?
      ignore = ''
    elsif (ignore = Regexp.compile(@config[0]['ignore'], Regexp::MULTILINE))
    end
    `ncalcli "#{date}"`.lines.map do |line|
      s = line.split(/\t/)
      t = s[2].to_f
      summary = s[3].chomp
      summary =~ /#(\d{3,})/
      unless ignore.match(summary)
        issue = $1
        {
            date: date,
            time: t,
            text: summary,
            issue: issue,
        }
      end
    rescue StandardError => e
      {
        date: date,
        time: 0.0,
        text: line.chomp,
        error: e.message
      }
    end
  end
end
