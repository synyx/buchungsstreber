class Buchungsstreber::Generator::Mention
  include Buchungsstreber::Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    `cmm #{date}`.lines.map do |line|
      next unless line =~ /^\d+/

      s = line.split(/\t/)
      Buchungsstreber::Entry.new(
        date: date,
        issue: s[0],
        time: s[1].to_f,
        comment: "Mention from #{s[2]} in project #{s[4]}".chomp,
        text: s[3].chomp,
      )
    end
  end
end
