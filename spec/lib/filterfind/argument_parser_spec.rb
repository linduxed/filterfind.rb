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
    end
  end
end
