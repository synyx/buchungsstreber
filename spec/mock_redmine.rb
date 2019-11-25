class MockRedmine

  def add_time(entry)
    true
  end

  def valid_activity?(activity)
    true
  end

  def get_issue(issue_id)
    "Subject"
  end
end
