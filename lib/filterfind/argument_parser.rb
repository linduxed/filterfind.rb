require 'optparse'

module Filterfind
  class ArgumentParser
    def initialize(unparsed_args)
      @unparsed_args = unparsed_args
    end

    def parse
      opt_hash = {}

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: filterfind [options]'

        opts.on('-e [REGEX]', String,
          'REGEX must match a line in a file') do |regex|
          if opt_hash[:regexes]
            opt_hash[:regexes] << regex
          else
            opt_hash[:regexes] = [regex]
          end
        end

        opts.on('-i [REGEX]', String,
          'REGEX must match a line in a file (case insensitive)') do |regex|
          if opt_hash[:case_insensitive_regexes]
            opt_hash[:case_insensitive_regexes] << regex
          else
            opt_hash[:case_insensitive_regexes] = [regex]
          end
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
