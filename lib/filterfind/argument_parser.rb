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
          '-d',
          '--dotfiles',
          'Allows the inclusion of dotfiles in the list of parsed files.'
        ) do
          opt_hash[:dotfiles_allowed] = true
        end

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

      populator = OptHashPopulator.new(
        opt_hash: opt_hash,
        paths: non_flag_args,
      )
      populator.hash_with_filenames
    rescue
      $stderr.puts parser.banner
      raise
    end

    private

    def regexes_present?(hash)
      hash.key?(:regexes) || hash.key?(:case_insensitive_regexes)
    end
  end

  class OptHashPopulator
    def initialize(opt_hash:, paths:)
      @opt_hash = opt_hash
      @paths = paths
      @dotfiles_allowed = opt_hash[:dotfiles_allowed] || false

      add_regex_key_if_missing
    end

    def hash_with_filenames
      if @paths.empty?
        filenames = FileFinder.all_filenames_in_cwd(@dotfiles_allowed)
      else
        filenames = FileFinder.new(@paths, @dotfiles_allowed).expand_paths
      end

      @opt_hash.merge(filenames: filenames)
    rescue FileFinder::InvalidPath => error
      raise(InvalidPathArgument, error.message)
    end

    private

    def add_regex_key_if_missing
      [:regexes, :case_insensitive_regexes].each do |key|
        @opt_hash[key] = [] if @opt_hash[key].nil?
      end
    end
  end

  class FileFinder
    class InvalidPath < StandardError; end

    def self.all_filenames_in_cwd(dotfiles_allowed)
      new(['.'], dotfiles_allowed).expand_paths
    end

    def initialize(paths, dotfiles_allowed)
      @paths = paths
      @dotfiles_allowed = dotfiles_allowed
    end

    def expand_paths
      check_all_paths_exist
      expanded_paths = paths_with_directories_expanded

      if @dotfiles_allowed
        expanded_paths
      else
        reject_dot_paths(
          full_paths: expanded_paths,
          allowed_prefixes: @paths
        )
      end
    end

    private

    def check_all_paths_exist
      bad_paths = @paths.reduce([]) do |bad, path|
        File.exist?(path) ? bad : bad << path
      end

      unless bad_paths.empty?
        raise(InvalidPath, "invalid paths: #{bad_paths.join(', ')}")
      end
    end

    def paths_with_directories_expanded
      @paths.map do |path|
        if FileTest.directory?(path)
          reject_directory_paths(Find.find(path))
        else
          path
        end
      end.flatten
    end

    def reject_directory_paths(paths)
      paths.reject { |path| FileTest.directory?(path) }
    end

    def reject_dot_paths(full_paths:, allowed_prefixes:)
      full_paths.reject do |path|
        prefix = allowed_prefixes.find { |prefix| path.match(/\A#{prefix}/) }
        path.sub(prefix, '').match(%r{/\..+})
      end
    end
  end
end
