class Generator::XChat
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `cmx #{date}`.lines.map do |line|
      if line =~ /(?:issues\/|#)(\d{3,5})/
        {
          date: date,
          issue: $1.to_i,
          comment: line.chomp,
        }
      end
    end.compact
  end
end
