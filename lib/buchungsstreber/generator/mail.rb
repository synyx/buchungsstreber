class Buchungsstreber::Generator::Mail
  include Buchungsstreber::Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    re = /Subject: ([^\r\n]*)\s*/m
    `cmi #{date} 2>/dev/null`.to_enum(:scan, re).map do
      match = Regexp.last_match
      subj = match[1].gsub(/(re|fwd|wg|aw|fw):\s*/i, '').gsub(/[\r\n]+/m, ' ')
      Buchungsstreber::Entry.new(
        date: date,
        comment: "Mail: #{subj}".chomp,
      )
    end.compact.uniq
  end
end
