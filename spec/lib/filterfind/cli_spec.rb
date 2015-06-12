require 'spec_helper'

module Filterfind
  describe CLI do
    describe '#run' do
      it 'returns a list of strings' do
        with_stubbed_stdout do
          output_text = "firstFileName\nsecondFileName"
          output_generator = double(:output_generator, lines: output_text)
          allow(CommandLineOutput).to receive(:new).and_return(output_generator)
          empty_args = []

          CLI.new(args: empty_args).run

          expect($stdout.string).to match(output_text)
        end
      end

      it 'forwards arguments to a parser' do
        with_stubbed_stdout do
          parser = double(parse: {})
          allow(ArgumentParser).to receive(:new).and_return(parser)
          input_args = %w[-n 3]

          CLI.new({ args: input_args }).run

          expect(ArgumentParser).to have_received(:new).with(input_args)
        end
      end

      it 'forwards a provided options-hash to the output generator' do
        with_stubbed_stdout do
          silent_output = double(:silent_output)
          allow(silent_output).to receive(:lines)
          empty_args = []
          args_and_options = { args: empty_args, foo: 'foo' }
          allow(CommandLineOutput).to receive(:new).and_return(silent_output)

          CLI.new(args_and_options).run

          expect(CommandLineOutput).to have_received(:new).with(foo: 'foo')
        end
      end

      context 'both arguments and options are provided' do
        it 'merges opts and args then forwards the result' do
          with_stubbed_stdout do
            parsed_args = { amount_of_passwords: 3 }
            parser = double(:arg_parser, parse: parsed_args)
            allow(ArgumentParser).to receive(:new).and_return(parser)
            silent_output = double(:silent_output)
            allow(silent_output).to receive(:lines)
            allow(CommandLineOutput).to receive(:new).and_return(silent_output)

            CLI.new(args: 'stubbed', min_password_length: 10).run

            merged_options = {
              min_password_length: 10,
              amount_of_passwords: 3
            }
            expect(CommandLineOutput).to have_received(:new)
              .with(merged_options)
          end
        end

        it 'merges opts and args, but lets options take precedence' do
          with_stubbed_stdout do
            parsed_args = { amount_of_passwords: 3 }
            parser = double('arg_parser', parse: parsed_args)
            allow(ArgumentParser).to receive(:new).and_return(parser)
            silent_output = double('silent_output')
            allow(silent_output).to receive(:lines)
            allow(CommandLineOutput).to receive(:new).and_return(silent_output)

            CLI.new(
              args: 'whatever parses into { amount_of_passwords: 3 }',
              amount_of_passwords: 10,
              min_password_length: 10
            ).run

            merged_options = {
              min_password_length: 10,
              amount_of_passwords: 10
            }
            expect(CommandLineOutput).to have_received(:new)
              .with(merged_options)
          end
        end
      end
    end
  end
end
