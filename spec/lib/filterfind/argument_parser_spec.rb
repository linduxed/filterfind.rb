require 'spec_helper'

module Filterfind
  describe ArgumentParser do
    around(:example) do |example|
      with_stubbed_stderr(&example)
    end

    describe '#parse' do
      it 'prints a usage message if an invalid option is provided' do
        bad_args = %w[-foo bar]

        expect do
          ArgumentParser.new(bad_args).parse
        end.to raise_error(OptionParser::InvalidOption)
        expect($stderr.string).to match(/Usage:/)
      end

      describe 'flags' do
        describe '"-e"' do
          it 'adds a regex string to a regex list in the output hash' do
            args = %w[-e foobar]
            expected_hash = { regexes: ['foobar'] }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(parsed_arguments).to include(expected_hash)
          end

          it 'adds multiple regexes when flag is used multiple times' do
            args = %w[-e foo -e bar -e quux]
            expected_hash = { regexes: %w[foo bar quux] }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(parsed_arguments).to include(expected_hash)
          end
        end

        describe '"-i"' do
          it 'adds a regex string to a regex list in the output hash' do
            args = %w[-i foobar]
            expected_hash = { case_insensitive_regexes: ['foobar'] }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(parsed_arguments).to include(expected_hash)
          end

          it 'adds multiple regexes when flag is used multiple times' do
            args = %w[-i foo -i bar -i quux]
            expected_hash = { case_insensitive_regexes: %w[foo bar quux] }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(parsed_arguments).to include(expected_hash)
          end
        end

        describe '"-d"' do
          it 'allows adding dotfiles into filename list when finding files'
        end

        context 'no regex input flags were used' do
          it 'raises an error' do
            args = []

            expect do
              ArgumentParser.new(args).parse
            end.to raise_error(NoRegexesProvided)
          end
        end
      end
    end
  end
end
