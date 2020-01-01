class Generator::GCalc
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `gcalcli --tsv agenda "#{date}T06:00-1:00" "#{date}T22:00-1:00"`.lines.map do |line|
      s = line.split(/\t/)
      t = (Time.parse("#{s[2]} #{s[3]}") - Time.parse("#{s[0]} #{s[1]}")) / 3600
      {
          date: date,
          time: t,
          text: s[4].chomp,
      }
    end
  end
end
