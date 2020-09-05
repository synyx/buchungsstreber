RSpec::Matchers.define :fail_with do |message|
  match do |block|
    res, output = fake_stderr(&block)
    output.include?(message) && res == false
  end

  description do |block|
    _, output = fake_stderr(&block)
    "warn about \"#{message}\", got \"#{output}\""
  end

  failure_message do
    "expected to #{description}"
  end

  failure_message_when_negated do
    "expected to not #{description}"
  end

  def supports_block_expectations?
    true
  end

  # Fake STDERR and return a string written to it.
  def fake_stderr
    original_stderr = $stderr
    $stderr = StringIO.new
    res = yield
    [res, $stderr.string]
  ensure
    $stderr = original_stderr
  end
end
