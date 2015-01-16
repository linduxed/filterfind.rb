require 'spec_helper'

describe Executable do
  describe '#lines' do
    it 'returns a list of strings' do
      output = StringIO.new("foo\nbar\nbaz\n")
      allow(Open3).to receive(:popen3).and_return(
        [double, output, double, double])

      lines = Executable.run.lines

      expect(lines).not_to be_empty
      expect(lines.map(&:class)).to be_all { |c| c == String }
    end

    it 'returns the same result if invoked multiple times' do
      output = StringIO.new("foo\nbar\nbaz\n")
      allow(Open3).to receive(:popen3).and_return(
        [double, output, double, double])
      executable = Executable.run

      first_invocation = executable.lines
      second_invocation = executable.lines

      expect(first_invocation).to eq(second_invocation)
    end
  end

  describe '#error' do
    it 'returns the error string' do
      error = Executable.run('-foo bar').error

      expect(error).to be_a String
    end

    it 'returns the same result if invoked multiple times' do
      executable = Executable.run('-foo bar')

      first_invocation = executable.error
      second_invocation = executable.error

      expect(first_invocation).to eq(second_invocation)
    end
  end

  describe '#exit_code' do
    it 'returns an integer' do
      exit_code = Executable.run.exit_code

      expect(exit_code).to be_a Fixnum
    end
  end
end
