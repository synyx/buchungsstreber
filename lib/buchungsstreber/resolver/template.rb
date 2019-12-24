require_relative '../entry'

class TemplateResolver
  include Resolver::Base

  def initialize(config)
    @templates = config[:templates]
  end

  def resolve(entry)
    return entry unless @templates.key?(entry.activity)

    template = @templates[activity]

    if template['issue']
      _, redmine, issue = template['issue'].match(/^([a-z]*)(\d+)$/i).to_a
      entry.issue ||= issue
      entry.redmine ||= redmine
    end

    entry.activity = template['activity']
    entry.text ||= template['text']
  end
end
