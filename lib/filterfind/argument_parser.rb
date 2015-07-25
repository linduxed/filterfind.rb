require 'optparse'
require 'find'

module Filterfind
  class NoRegexesProvided < StandardError; end
  class InvalidPathArgument < StandardError; end

  class ArgumentParser
    def initialize(unparsed_args)
      @unparsed_args = unparsed_args
    end

    def parse
      opt_hash = {}

      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: filterfind [[-e REGEX] ...] [[-i REGEX] ...] ' \
          'PATH ...'

        opts.on(
          '-e [REGEX]',
          String,
          'REGEX must match a line in a file. Can be used multiple times.'
        ) do |regex|
          if opt_hash[:regexes]
            opt_hash[:regexes] << regex
          else
            opt_hash[:regexes] = [regex]
          end
        end

        opts.on(
          '-i [REGEX]',
          String,
          'REGEX must match a line in a file (case insensitive). ' \
          'Can be used multiple times.'
        ) do |regex|
          if opt_hash[:case_insensitive_regexes]
            opt_hash[:case_insensitive_regexes] << regex
          else
            opt_hash[:case_insensitive_regexes] = [regex]
          end
        end
      end

      non_flag_args = parser.permute(@unparsed_args)

      unless regexes_present?(opt_hash)
        raise(NoRegexesProvided, 'No regular expressions provided.')
      end

      add_regex_key_if_missing!(opt_hash)
      opts_with_filenames(opt_hash, non_flag_args)
    rescue
      $stderr.puts parser.banner
      raise
    end

    private

    def regexes_present?(hash)
      hash.key?(:regexes) || hash.key?(:case_insensitive_regexes)
    end

    def add_regex_key_if_missing!(opt_hash)
      [:regexes, :case_insensitive_regexes].each do |key|
        opt_hash[key] = [] if opt_hash[key].nil?
      end
    end

    def opts_with_filenames(opt_hash, paths)
      if paths.empty?
        opt_hash.merge(filenames: recursively_find_all_files_in_cwd)
      else
        opt_hash.merge(filenames: check_all_paths_exist(paths))
      end
    end

    def recursively_find_all_files_in_cwd
      Find.find('.').reject { |path| FileTest.directory?(path) }
    end

    def check_all_paths_exist(paths)
      bad_paths = paths.reduce([]) do |bad, path|
        File.exist?(path) ? bad : bad << path
      end

      if bad_paths.empty?
        paths
      else
        raise(InvalidPathArgument, "invalid paths: #{bad_paths.join(', ')}")
      end
    end
  end
end
