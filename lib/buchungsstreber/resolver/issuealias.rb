class Buchungsstreber::Resolver::IssueAlias
  include Buchungsstreber::Resolver::Base

  def initialize(config)
    @issues = config || {}
  end

  def resolve(entry)
    entry.issue = @issues[entry.issue] if @issues.key? entry.issue
  end
end
