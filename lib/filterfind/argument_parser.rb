require 'optparse'

module Filterfind
  class NoRegexesProvided < StandardError; end

  class ArgumentParser
    def initialize(unparsed_args)
      @unparsed_args = unparsed_args
    end

    def parse
      opt_hash = {}

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: filterfind [-e REGEX] [-i REGEX] [options]'

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

      unless regexes_present?(opt_hash)
        raise(NoRegexesProvided, 'No regular expressions provided.')
      end

      opt_hash
    rescue
      $stderr.puts parser.banner
      raise
    end

    private

    def regexes_present?(hash)
      hash.key?(:regexes) || hash.key?(:case_insensitive_regexes)
    end
  end
end
