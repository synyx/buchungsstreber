class Buchungsstreber::Generator::XChat
  include Buchungsstreber::Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `cmx #{date} 2>/dev/null`.lines.map do |line|
      next unless line =~ /(?:issues\/|#)(\d{3,5})/

      {
        date: date,
        issue: $1.to_i,
        comment: line.chomp,
      }
    end.compact
  end
end
