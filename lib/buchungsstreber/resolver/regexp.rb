class Resolver::Regexp
  include Resolver::Base

  def initialize(config)
    @config = config
  end

  def resolve(entry)
    text = [entry[:text], entry[:comment]].join("\n")
    @config.each do |c|
      re = Regexp.compile(c['re'], Regexp::IGNORECASE | Regexp::MULTILINE)
      if re.match(text)
        entry[:issue] ||= c['entry']['issue']
        entry[:redmine] ||= c['entry']['redmine']
        entry[:activity] ||= c['entry']['activity']
        entry[:text] ||= c['entry']['text']
        entry[:time] ||= c['entry']['time']
      end
    end
  end
end
