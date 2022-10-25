class Buchungsstreber::Generator::NCalCLI
  include Buchungsstreber::Generator::Base

  def initialize(config)
    @config = config
    if @config.empty?
      @ignore = /(?!)/
    else
      @ignore = Regexp.compile(@config['ignore'])
    end
  end

  def generate(date)
    `ncalcli "#{date}"`.lines.map do |line|
      s = line.split(/\t/)
      t = s[2].to_f
      summary = s[3].chomp
      summary =~ /#(\d{3,})/
      unless @ignore.match(summary)
        issue = $1
        Buchungsstreber::Entry.new(
          date: date,
          time: t,
          text: summary,
          issue: issue,
        )
      end
    rescue StandardError => e
      [Buchungsstreber::Entry.new(
        date: date,
        time: 0.0,
        text: line.chomp,
        errors: e.message
      )]
    end
  end
end
