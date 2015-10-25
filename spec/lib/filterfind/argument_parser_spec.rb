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
          context 'when not used' do
            context 'user provides dot paths as arguments' do
              it 'adds regular files from provided dot path' do
                Dir.mktmpdir('.dot_dir') do |dot_dir|
                  args = ['-e', 'some_regex', dot_dir]
                  dotfile = Tempfile.new('.dotfile', dot_dir)
                  dotfile.close
                  regular_file = Tempfile.new('regular_file', dot_dir)
                  regular_file.close

                  parsed_arguments = ArgumentParser.new(args).parse

                  expect(parsed_arguments.fetch(:filenames)).to include(
                    regular_file.path)
                  expect(parsed_arguments.fetch(:filenames)).not_to include(
                    dotfile.path)

                  [dotfile, regular_file].each(&:delete)
                end
              end
            end

            it 'does not add dotfiles into filename list when finding files' do
              Dir.mktmpdir do |wrapping_dir|
                args = ['-e', 'some_regex', wrapping_dir]
                dotfile = Tempfile.new('.dotfile', wrapping_dir)
                dotfile.close
                regular_file = Tempfile.new('regular_file', wrapping_dir)
                regular_file.close

                parsed_arguments = ArgumentParser.new(args).parse

                expect(parsed_arguments.fetch(:filenames)).to include(
                  regular_file.path)
                expect(parsed_arguments.fetch(:filenames)).not_to include(
                  dotfile.path)

                [dotfile, regular_file].each(&:delete)
              end
            end
          end

          context 'when used' do
            it 'adds dotfiles into filename list when finding files' do
              Dir.mktmpdir do |wrapping_dir|
                args = ['-e', 'some_regex', '-d', wrapping_dir]
                dotfile = Tempfile.new('.dotfile', wrapping_dir)
                dotfile.close

                parsed_arguments = ArgumentParser.new(args).parse

                expect(parsed_arguments.fetch(:filenames)).to include(
                  dotfile.path)

                dotfile.delete
              end
            end
          end
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

      describe 'trailing path arguments' do
        context 'no paths provided' do
          it 'adds all files recursively from working dir to output hash' do
            args = %w[-e some_regex]
            filename = 'foo_file'
            allow(Find).to receive(:find).with('.')
              .and_return([filename])
            allow(FileTest).to receive(:directory?).with('.')
              .and_return(true)
            allow(FileTest).to receive(:directory?).with(filename)
              .and_return(false)
            expected_hash = { filenames: [filename] }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(Find).to have_received(:find).with('.')
            expect(parsed_arguments).to include(expected_hash)
          end
        end

        context 'valid paths provided' do
          context 'directory provided' do
            it 'recursively adds all files in dir and subdirs' do
              Dir.mktmpdir do |wrapping_dir|
                args = ['-e', 'some_regex', wrapping_dir]
                first_file = Tempfile.new('first', wrapping_dir)
                first_file.close
                second_file = Tempfile.new('second', wrapping_dir)
                second_file.close

                parsed_arguments = ArgumentParser.new(args).parse

                expect(parsed_arguments).to include(
                  filenames: [first_file.path, second_file.path]
                )

                [first_file, second_file].each(&:delete)
              end
            end
          end

          it 'adds the provided paths (recursively if dirs) to output hash' do
            args = %w[-e some_regex foo_file bar_file]
            list_of_filenames = %w[foo_file bar_file]
            allow(File).to receive(:exist?).and_return(true)
            expected_hash = { filenames: list_of_filenames }

            parsed_arguments = ArgumentParser.new(args).parse

            expect(parsed_arguments).to include(expected_hash)
          end
        end

        context 'invalid paths provided' do
          it 'raises an error' do
            args = %w[-e foobar invalid_file]
            allow(File).to receive(:exist?).and_return(false)

            expect do
              ArgumentParser.new(args).parse
            end.to raise_error(InvalidPathArgument)
          end
        end
      end
    end
  end
end
