def with_stubbed_stdout(&block)
  orig_stdout = $stdout
  $stdout = StringIO.new
  yield(block)
ensure
  $stdout = orig_stdout
end

def with_stubbed_stderr(&block)
  orig_stderr = $stderr
  $stderr = StringIO.new
  yield(block)
ensure
  $stderr = orig_stderr
end
