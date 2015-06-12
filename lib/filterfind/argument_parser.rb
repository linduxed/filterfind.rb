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
      end

      parser.parse(@unparsed_args)

      opt_hash
    rescue
      $stderr.puts parser.banner
      raise
    end
  end
end
