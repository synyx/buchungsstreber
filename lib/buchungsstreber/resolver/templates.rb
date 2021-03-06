class Buchungsstreber::Resolver::Templates
  include Buchungsstreber::Resolver::Base

  def initialize(config)
    @templates = config
  end

  def resolve(entry)
    return entry unless @templates.key?(entry[:activity])

    template = @templates[entry[:activity]]

    if template['issue']
      _, redmine, issue = template['issue'].match(/^([a-z]*)(\d+)$/i).to_a
      entry[:issue] ||= issue
      entry[:redmine] ||= redmine
    end

    entry[:activity] = template['activity']
    entry[:text] ||= template['text']
  end
end
