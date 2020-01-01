class Generator::Mention
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `cmm #{date}`.lines.map do |line|
      if line =~ /^\d+/
        s = line.split(/\t/)
        {
            date: date,
            issue: s[0],
            time: s[1].to_f,
            comment: "Mention from #{s[2]} in Project #{s[4]}".chomp,
            text: s[3].chomp,
        }
      end
    end
  end
end
