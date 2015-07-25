module Filterfind
  class MissingOptionError < StandardError; end

  class CommandLineOutput
    def initialize(options={})
      @filenames = options.fetch(:filenames) { raise MissingOptionError }
      @regexes = options.fetch(:regexes)
        .map { |regex| Regexp.new(regex, false) }
      @case_insensitive_regexes = options.fetch(:case_insensitive_regexes)
        .map { |regex| Regexp.new(regex, true) }

      raise MissingOptionError if @regexes.nil? &&
          @case_insensitive_regexes.nil?
    end

    def lines
      if filtered_filenames.empty?
        ''
      else
        filtered_filenames.join("\n") + "\n"
      end
    end

    private

    def filtered_filenames
      @filtered_filenames ||= @filenames.select do |filename|
        matching_regexes = []

        File.readlines(filename).each do |line|
          all_regexes.each do |regex|
            matching_regexes << regex if line =~ regex
          end
        end

        all_regexes_matched?(matching_regexes)
      end
    end

    def all_regexes
      @all_regexes ||= @regexes + @case_insensitive_regexes
    end

    def all_regexes_matched?(regexes)
      all_regexes - regexes == []
    end
  end
end
