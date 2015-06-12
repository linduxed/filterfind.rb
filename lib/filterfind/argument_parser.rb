require 'optparse'

module Filterfind
  class ArgumentParser
    def initialize(unparsed_args)
      @unparsed_args = unparsed_args
    end

    def parse
      opt_hash = { regexes: [] }

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: filterfind [options]'

        opts.on('-e [REGEX]', String,
          'REGEX must match a line in a file') do |regex|
          opt_hash[:regexes] << regex
        end
      end

      parser.parse(@unparsed_args)

      opt_hash
    rescue
      $stderr.puts parser.banner
      raise
    end
  end
end
