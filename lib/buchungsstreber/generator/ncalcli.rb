class Generator::NCalCLI
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `ncalcli "#{date}"`.lines.map do |line|
      begin
        s = line.split(/\t/)
        t = s[2].to_f
        summary = s[3].chomp
        summary =~ /#(\d{3,})/
        issue = $1
        {
            date: date,
            time: t,
            text: summary,
            issue: issue,
        }
      rescue => e
        {
          date: date,
          time: 0.0,
          text: line.chomp,
          error: e.message
        }
      end
    end
  end
end
