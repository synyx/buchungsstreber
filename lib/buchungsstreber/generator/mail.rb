class Generator::Mail
  include Generator::Base

  def initialize(config)
    @config = config
  end

  def generate(date)
    re = /< To:[^<]*<([^>]*)>\s*< Subject: ([^\r\n]*)\s*/m
    `cmi #{date}`.to_enum(:scan, re).map do
      match = Regexp.last_match
      subj = match[2].gsub(/(re|fwd|wg|aw|fw):\s*/i, '')
      {
        date: date,
        comment: "Mail to #{match[1]}: #{subj}".chomp,
      }
    end
  end
end
