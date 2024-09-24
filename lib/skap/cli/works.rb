# frozen_string_literal: true

module Skap
  module CLI::Works
    include Command
    extend self

    # @param command [String]
    # @param args [Array<String>]
    # @return [void]
    def start(command, args)
      assert_cwd

      case command
      when "covered" then covered(*args)
      when "ignored" then ignored(*args)
      when "publish" then publish(*args)
      when "outdated" then outdated(*args)
      when "uncovered" then uncovered(*args)
      when "unknown" then unknown(*args)
      else
        raise ArgumentError, "Unknown command: #{command}"
      end
    end

    private

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

    # @param path [String]
    # @return [String]
    def commit_sha(path)
      dir, file = File.split(path)

      shell("git rev-parse HEAD -- #{file}", dir:).split("\n").first
    end

    # @param dirs [Array<String>]
    # @return [void]
    def covered(*dirs)
      sources = Files::Sources.new.extract("indexed", dirs)

      puts (Files::Versions.new.covered_sources & collect_files(sources)).sort
    end

    # @param dirs [Array<String>]
    # @return [void]
    def ignored(*dirs)
      sources = Files::Sources.new.extract("ignored", dirs)

      puts collect_files(sources).sort
    end

    # @param dirs [Array<String>]
    # @return [void]
    def outdated(*dirs)
      outdated_documents =
        Files::Versions.new.outdated_documents do |source_path|
          dirs.empty? || source_path.start_with?(*dirs) ? commit_sha(source_path) : nil
        end

      outdated_documents.each do |(doc_path, outdated_sources)|
        puts doc_path, outdated_sources.map { |x| "* #{x}" }, ""
      end
    end

    # @param document_path [String]
    # @param sources_paths [Array<String>]
    # @return [void]
    def publish(document_path, *sources_paths)
      excluded_file_paths = sources_paths.select { |x| x.start_with?("-") }
      added_file_paths = sources_paths - excluded_file_paths

      excluded_file_paths.map! { |x| x[1..] }

      versions = Files::Versions.new
      today = Time.now.strftime("%F")
      doc = versions.find_document(document_path) || {}

      doc["date"] = today
      doc["sources"] ||= {}

      added_file_paths.each do |path|
        entry = (doc["sources"][path] ||= {})
        entry["date"] = today
        entry["sha"] = commit_sha(path)
      end

      excluded_file_paths.each { |x| doc["sources"].delete(x) }

      versions.add_document(document_path, doc)

      puts "Version updated for #{document_path} in #{Files::Versions.file_name}"
    end

    # @param dirs [Array<String>]
    # @return [void]
    def uncovered(*dirs)
      sources = Files::Sources.new.extract("indexed", dirs)

      puts (collect_files(sources) - Files::Versions.new.covered_sources.to_a).sort
    end

    # @param dirs [Array<String>]
    # @return [void]
    def unknown(*dirs)
      sources_data = Files::Sources.new
      sources_data.select_directories!(dirs) if !dirs.empty?

      search_patterns = sources_data.extract("file-extensions").transform_values { |v| v.join(",") }

      all_files =
        search_patterns.reduce([]) { |a, (dir, ext)| a + Dir.glob("#{dir}/**/*.{#{ext}}") }

      ignored_files = collect_files(sources_data.extract("ignored"))
      indexed_files = collect_files(sources_data.extract("indexed"))

      puts (all_files - ignored_files - indexed_files).sort
    end
  end
end
