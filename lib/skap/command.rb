# frozen_string_literal: true

module Skap
  module Command
    CURRENT_DIR = Dir.pwd.freeze
    SKAP_DIR = File.expand_path("../..", __dir__).freeze

    MENU = "menu.yaml"
    SOURCES = "sources.yaml"
    VERSIONS = "versions.yaml"

    private

    # @return [void]
    def assert_cwd
      raise "Current dir isn't a repo for sources" if !File.exist?(SOURCES)
    end

    # @param args [Array<String>]
    # @return [void]
    def assert_empty_options(args)
      raise ArgumentError, "Unknown options: #{args.inspect}" if !args.empty?
    end

    # @param paragraph [String]
    # @param max_width [Integer]
    # @return [Array<String>]
    def break_words(paragraph, max_width)
      words = paragraph.split
      parts = [[]]
      line_width = 0

      while !words.empty?
        word_size = words.first.size
        is_line_empty = line_width == 0

        if (is_line_empty ? line_width : line_width + 1) + word_size <= max_width
          parts.last << words.shift
          line_width += (is_line_empty ? 0 : 1) + word_size
          parts << [] if line_width == max_width
        else
          parts << [words.shift]
          line_width = word_size
        end
      end

      parts.pop if parts.last.empty?

      parts.map { |line| line.join(" ") }
    end

    # @param path_patterns_as_hash [Hash<String, Array<String>>]
    # @return [Array<String>]
    def collect_files(path_patterns_as_hash)
      path_patterns_as_array =
        path_patterns_as_hash.flat_map { |dir, paths| paths.map { |x| File.join(dir, x) } }

      path_patterns_as_array.flat_map do |path_pattern|
        if path_pattern.include?("*")
          result = Dir.glob(path_pattern, base: CURRENT_DIR)
          if result.empty?
            raise ArgumentError, "No files found for path pattern \"#{path_pattern}\""
          end

          result
        else
          if !File.exist?(path_pattern)
            raise ArgumentError, "File \"#{path_pattern}\" doesn't exist"
          end

          path_pattern
        end
      end
    end

    # @return [Set<String>]
    def covered_sources
      versions = load_file(VERSIONS)
      result = Set.new

      versions.each_value { |value| result.merge(value["sources"].keys) }

      result
    end

    # @param key [String]
    # @param sources [Hash<String, Hash<String, Array<String>>>]
    # @return [Hash<String, Array<String>>]
    def extract_from_sources(key, sources = load_file(SOURCES))
      sources
        .transform_values { |v| v[key] }
        .reject { |_, v| v.nil? || v.empty? }
    end

    # @param path [String]
    # @return [Hash<String, Object>]
    def load_file(path)
      Psych.load_file(path, symbolize_names: false) || {}
    end

    # @param text [String]
    # @param indent [String]
    # @param max_width [Integer]
    # @return [void]
    def output_menu_item_text(text, indent, max_width)
      if text.is_a?(Array)
        text.each do |paragraph|
          break_words(paragraph, max_width).each { |line| puts "#{indent}#{line}" }
        end
      else
        puts "#{indent}#{text}"
      end
    end

    # @param cmd [String]
    # @return [String]
    def shell(cmd, dir: "")
      dir = dir == "~" ? Dir.home : File.absolute_path(dir, CURRENT_DIR)
      `cd #{dir} && #{cmd}`.strip
    end
  end
end
