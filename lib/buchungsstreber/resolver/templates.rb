class Buchungsstreber::Resolver::Templates
  include Buchungsstreber::Resolver::Base

  def initialize(config)
    @templates = config
  end

  def resolve(entry)
    return entry unless @templates.key?(entry[:activity])

    template = @templates[entry[:activity]]

    entry[:issue] ||= template['issue'] if template['issue']
    entry[:activity] = template['activity']
    entry[:text] ||= template['text']
  end
end
