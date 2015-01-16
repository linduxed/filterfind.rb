require 'open3'

class Executable
  def self.run(args_string = '')
    new(args_string).tap(&:run)
  end

  def initialize(args_string = '')
    @args_string = args_string
  end

  def run
    _, @stdout, @stderr, @wait_thr = Open3.popen3(
      "#{binary_location} #{args_string}")
  end

  def lines
    @lines ||= @stdout.readlines.map(&:chomp)
  end

  def error
    @error ||= @stderr.read
  end

  def exit_code
    @wait_thr.value.exitstatus
  end

  private

  attr_reader :args_string

  def binary_location
    File.expand_path('../../../../bin/filterfind', __FILE__)
  end
end
