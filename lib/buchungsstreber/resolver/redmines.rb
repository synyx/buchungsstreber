require_relative '../validator'

class Resolver::Redmines
  include Resolver::Base

  def initialize(config)
    @redmines = Redmines.new(config)
  end

  def resolve(entry)
    return unless entry[:issue] # need issue for resolving
    return unless entry[:comment] # only resolve when in need of comment

    redmine = @redmines.get(entry[:redmine])
    issue = redmine.get_issue(entry[:issue])
    entry[:comment] = entry[:comment] + ', issue: ' + issue unless entry[:comment].include?(issue)
  end
end
