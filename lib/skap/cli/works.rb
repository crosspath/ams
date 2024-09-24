# frozen_string_literal: true

module Skap
  module CLI::Works
    include Command
    extend self

    NO_ARGS = %w[covered ignored outdated uncovered unknown].freeze

    # @param command [String]
    # @param args [Array<String>]
    # @return [void]
    def start(command, args)
      assert_cwd
      assert_empty_options(args) if NO_ARGS.include?(command)

      case command
      when "covered" then covered
      when "ignored" then ignored
      when "publish" then publish(*args)
      when "outdated" then outdated
      when "uncovered" then uncovered
      when "unknown" then unknown
      else
        raise ArgumentError, "Unknown command: #{command}"
      end
    end

    private

    # @param path [String]
    # @return [String]
    def commit_sha(path)
      dir, file = File.split(path)

      shell("git rev-parse HEAD -- #{file}", dir:).split("\n").first
    end

    # @return [void]
    def covered
      sources = extract_from_sources("indexed")

      puts (covered_sources & collect_files(sources)).sort
    end

    # @return [void]
    def ignored
      sources = extract_from_sources("ignored")

      puts collect_files(sources).sort
    end

    # @return [void]
    def outdated
      sources_sha = {}
      versions = load_file(VERSIONS)

      outdated_documents =
        versions.filter_map do |doc_path, hash|
          outdated_sources =
            hash["sources"].filter_map do |source_path, source_data|
              sources_sha[source_path] ||= commit_sha(source_path)
              source_path if sources_sha[source_path] != source_data["sha"]
            end
          [doc_path, outdated_sources] if !outdated_sources.empty?
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

      versions = load_file(VERSIONS)
      today = Time.now.strftime("%F")

      doc = (versions[document_path] ||= {})

      doc["date"] = today
      doc["sources"] ||= {}

      added_file_paths.each do |path|
        entry = (doc["sources"][path] ||= {})
        entry["date"] = today
        entry["sha"] = commit_sha(path)
      end

      excluded_file_paths.each { |x| doc["sources"].delete(x) }

      versions = versions.sort_by(&:first).to_h
      File.write(VERSIONS, Psych.dump(versions, line_width: 100))

      puts "Version updated for #{document_path} in #{VERSIONS}"
    end

    # @return [void]
    def uncovered
      sources = extract_from_sources("indexed")

      puts (collect_files(sources) - covered_sources.to_a).sort
    end

    # @return [void]
    def unknown
      sources_data = load_file(SOURCES)

      search_patterns =
        extract_from_sources("file-extensions", sources_data).transform_values { |v| v.join(",") }

      all_files =
        search_patterns.reduce([]) { |a, (dir, ext)| a + Dir.glob("#{dir}/**/*.{#{ext}}") }

      ignored_files = collect_files(extract_from_sources("ignored", sources_data))
      indexed_files = collect_files(extract_from_sources("indexed", sources_data))

      puts (all_files - ignored_files - indexed_files).sort
    end
  end
end
