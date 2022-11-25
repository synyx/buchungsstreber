class Buchungsstreber::Resolver::IssueRef
  include Buchungsstreber::Resolver::Base

  ISSUE_REGEX = /^([a-z]+)(\d+)$/i.freeze

  def initialize(config)
    @config = config
  end

  def resolve(entry)
    return unless entry[:issue] # need issue for resolving
    return if entry[:redmine] # return if already has redmine

    issue_ref = entry[:issue]
    _, entry[:redmine], entry[:issue] = issue_ref.match(ISSUE_REGEX).to_a if issue_ref =~ ISSUE_REGEX
  end
end
