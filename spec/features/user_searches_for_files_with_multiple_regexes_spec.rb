require 'spec_helper'
require 'tempfile'

describe 'Searching for files with multiple regexes' do
  context 'file paths provided as arguments' do
    it 'returns filenames of the files where all regexes matched' do
      matching_file = Tempfile.new('matching')
      matching_file.write("correct\n123\nxxVALIDxx\n")
      matching_file.close
      partially_matching_file = Tempfile.new('partially_matching')
      partially_matching_file.write("wrong\nfoobar\ncorrect\n")
      partially_matching_file.close
      not_matching_file = Tempfile.new('not_matching')
      not_matching_file.write("xxx\nyyy\nzzz\n")
      not_matching_file.close

      executable = Executable.run(
        '-e "correct" -e "123" -i ".+valid.+" ' \
        "#{matching_file.path} " \
        "#{partially_matching_file.path} " \
        "#{not_matching_file.path}"
      )

      expected_output_lines = [matching_file.path]
      expect(executable.error).to be_empty, executable.error
      expect(executable.lines).to eq(expected_output_lines)

      [matching_file, partially_matching_file, not_matching_file].each(&:delete)
    end

    it 'returns no lines of output if no regexes matched' do
      file_without_foobar = Tempfile.new('no_foobar')
      file_without_foobar.write("baz\nquux")
      file_without_foobar.close

      executable = Executable.run(
        '-e "foobar" ' + "#{file_without_foobar.path}"
      )

      expect(executable.error).to be_empty, executable.error
      expect(executable.lines).to eq([])

      file_without_foobar.delete
    end
  end

  context 'no file paths provided as arguments' do
    context 'no files present in working directory' do
      it 'returns empty output' do
        Dir.mktmpdir do |empty_dir|
          Dir.chdir(empty_dir) do
            executable = Executable.run('-e "some_regex"')

            expect(executable.error).to be_empty, executable.error
            expect(executable.lines).to eq([])
          end
        end
      end
    end

    context 'files present in working directory' do
      it 'returns filenames of the files where all regexes matched'

      it 'returns filenames without leading dot dirs' do
        Dir.mktmpdir do |wrapping_dir|
          Dir.chdir(wrapping_dir) do
            matching_file = Tempfile.new('matching', wrapping_dir)
            matching_file.write("___\nfoobar\n___\n")
            matching_file.close

            executable = Executable.run('-e "foobar"')

            expect(executable.error).to be_empty, executable.error
            expect(executable.lines.size).to eq(1)
            expect(executable.lines.first).not_to match(%r{\A\./})

            matching_file.delete
          end
        end
      end
    end
  end
end
