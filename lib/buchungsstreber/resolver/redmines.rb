require_relative '../validator'

class Buchungsstreber::Resolver::Redmines
  include Buchungsstreber::Resolver::Base

  def initialize(config)
    @redmines = Buchungsstreber::Redmines.new(config)
  end

  def resolve(entry)
    return unless entry[:issue] # need issue for resolving
    return unless entry[:comment] # only resolve when in need of comment

    redmine = @redmines.get(entry[:redmine])
    issue = redmine.get_issue(entry[:issue])
    entry[:comment] = "#{entry[:comment]}, issue: #{issue}" unless entry[:comment].include?(issue)
  rescue StandardError => e
    entry[:errors] = e.message
  end
end
