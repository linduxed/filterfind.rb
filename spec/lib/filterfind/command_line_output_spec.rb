require 'spec_helper'

module Filterfind
  describe CommandLineOutput do
    describe '#initialize' do
      it 'raises error if options are is missing' do
        expect do
          CommandLineOutput.new
        end.to raise_error(MissingOptionError)
      end
    end

    describe '#lines' do
      it 'returns an empty string if there were no matching files' do
        first_no_match_file = 'first_bad_path'
        second_no_match_file = 'second_bad_path'
        allow(File).to receive(:readlines).with(first_no_match_file)
          .and_return(%w[completely wrong])
        allow(File).to receive(:readlines).with(second_no_match_file)
          .and_return(%w[completely wrong])

        output_lines = CommandLineOutput.new(
          filenames: [
            first_no_match_file,
            second_no_match_file
          ],
          regexes: ['foobar'],
          case_insensitive_regexes: []
        ).lines

        expect(output_lines).to eq('')
      end

      it 'returns filenames of the files where all regexes matched' do
        first_no_match_file = 'first_bad_path'
        second_no_match_file = 'second_bad_path'
        matching_file = 'matching_path'
        allow(File).to receive(:readlines).with(first_no_match_file)
          .and_return(%w[partially matching])
        allow(File).to receive(:readlines).with(second_no_match_file)
          .and_return(%w[completely wrong])
        allow(File).to receive(:readlines).with(matching_file)
          .and_return(%w[perfectly matching])

        output_lines = CommandLineOutput.new(
          filenames: [
            first_no_match_file,
            second_no_match_file,
            matching_file
          ],
          regexes: %w[matching perfectly],
          case_insensitive_regexes: []
        ).lines

        expect(output_lines).to eq("#{matching_file}\n")
      end
    end
  end
end
