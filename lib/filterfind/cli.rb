module Filterfind
  class CLI
    EX_USAGE = 64

    def initialize(options={})
      @unparsed_args = options.delete(:args) { ARGV }
      @non_arg_options = options
    end

    def run
      $stdout.puts CommandLineOutput.new(merged_options).lines
    rescue => error
      handle_error(error)
    end

    private

    attr_reader :unparsed_args, :non_arg_options

    def merged_options
      parsed_args.merge(non_arg_options)
    end

    def parsed_args
      ArgumentParser.new(unparsed_args).parse
    end

    def handle_error(error)
      case error
      when OptionParser::InvalidOption, OptionParser::MissingArgument,
        OptionParser::InvalidArgument
        $stderr.puts error.message
        exit EX_USAGE
      else
        raise error
      end
    end
  end
end
