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
        remove_leading_dot_dir(filtered_filenames).join("\n") + "\n"
      end
    end

    private

    def remove_leading_dot_dir(filenames)
      filenames.map do |filename|
        filename.gsub(%r{\A\./},'')
      end
    end

    def filtered_filenames
      @filtered_filenames ||= FileFilter.new(@filenames, all_regexes).filter
    end

    def all_regexes
      @all_regexes ||= @regexes + @case_insensitive_regexes
    end
  end

  class FileFilter
    def initialize(filenames, regexes)
      @filenames = filenames
      @regexes = regexes
    end

    def filter
      @filenames.select do |filename|
        File.open(filename) do |file|
          matching_regexes = []

          begin
            file.each_line do |line|
              @regexes.each do |regex|
                matching_regexes << regex if line =~ regex
              end
            end
          rescue ArgumentError
            false
          end

          all_regexes_matched?(matching_regexes)
        end
      end
    end

    private

    def all_regexes_matched?(matched_regexes)
      @regexes - matched_regexes == []
    end
  end
end
