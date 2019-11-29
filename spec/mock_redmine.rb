class MockRedmine
  def add_time(entry)
    entry && true
  end

  def valid_activity?(activity)
    activity && true
  end

  def get_issue(issue_id)
    issue_id && 'Subject'
  end
end
