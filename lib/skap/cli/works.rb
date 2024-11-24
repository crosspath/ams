# frozen_string_literal: true

# CLI command for managing works (files based on sources).
module Skap::CLI::Works
  include Skap::Command
  extend self

  # @param command [String]
  # @param args [Array<String>]
  # @return [void]
  def start(command, args) # rubocop:disable Metrics/MethodLength
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
    flatten_path_patterns(path_patterns_as_hash).flat_map do |path_pattern|
      find_files_by_pattern(path_pattern)
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
    sources = Skap::Files::Sources.new.extract("indexed", dir_names_without_slash(dirs))

    puts (Skap::Files::Versions.new.covered_sources & collect_files(sources)).sort
  end

  # @param dirs [Array<String>]
  # @return [Array<String>]
  def dir_names_with_slash(dirs)
    dirs.map { |x| x.end_with?("/") ? x : "#{x}/" }
  end

  # @param dirs [Array<String>]
  # @return [Array<String>]
  def dir_names_without_slash(dirs)
    dirs.map { |x| x.end_with?("/") ? x.chop : x }
  end

  # @param path_pattern [String]
  # @return [Array<String>]
  def find_files_by_pattern(path_pattern)
    if path_pattern.include?("*")
      result = Dir.glob(path_pattern, base: CURRENT_DIR)
      raise ArgumentError, "No files found for path pattern \"#{path_pattern}\"" if result.empty?

      result
    else
      raise ArgumentError, "File \"#{path_pattern}\" doesn't exist" if !File.exist?(path_pattern)

      path_pattern
    end
  end

  # @param hash [Hash<String, Array<String>>]
  # @return [Array<String>]
  def flatten_path_patterns(hash)
    hash.flat_map { |dir, paths| paths.map { |x| File.join(dir, x) } }
  end

  # @param dirs [Array<String>]
  # @return [void]
  def ignored(*dirs)
    sources = Skap::Files::Sources.new.extract("ignored", dir_names_without_slash(dirs))

    puts collect_files(sources).sort
  end

  # @param dirs [Array<String>]
  # @return [void]
  def outdated(*dirs)
    dirs = dir_names_with_slash(dirs)

    outdated_documents =
      Skap::Files::Versions.new.outdated_documents do |source_path|
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

    versions = Skap::Files::Versions.new
    doc = versions.find_document(document_path) || {}

    update_document_info(doc, added_file_paths, excluded_file_paths)
    versions.add_document(document_path, doc)

    puts "Version updated for #{document_path} in #{Skap::Files::Versions.file_name}"
  end

  # @param path_patterns_as_hash [Hash<String, Hash<String, Array<String>>>]
  # @return [Array<String>]
  def trackable_files(sources_data)
    sources_data
      .extract("file-extensions")
      .transform_values { |v| v.join(",") }
      .reduce([]) { |a, (dir, ext)| a + Dir.glob("#{dir}/**/*.{#{ext}}") }
  end

  # @param dirs [Array<String>]
  # @return [void]
  def uncovered(*dirs)
    sources = Skap::Files::Sources.new.extract("indexed", dir_names_without_slash(dirs))

    puts (collect_files(sources) - Skap::Files::Versions.new.covered_sources.to_a).sort
  end

  # @param dirs [Array<String>]
  # @return [void]
  def unknown(*dirs)
    sources_data = Skap::Files::Sources.new
    sources_data.select_directories!(dir_names_without_slash(dirs)) if !dirs.empty?

    all_files = trackable_files(sources_data)
    ignored_files = collect_files(sources_data.extract("ignored"))
    indexed_files = collect_files(sources_data.extract("indexed"))

    puts (all_files - ignored_files - indexed_files).sort
  end

  # @param doc [Hash<String, Object>]
  # @param added_file_paths [Array<String>]
  # @param excluded_file_paths [Array<String>]
  # @return [void]
  def update_document_info(doc, added_file_paths, excluded_file_paths)
    today = Time.now.strftime("%F")

    doc["date"] = today
    doc["sources"] ||= {}

    added_file_paths.each do |path|
      entry = (doc["sources"][path] ||= {})
      entry["date"] = today
      entry["sha"] = commit_sha(path)
    end

    excluded_file_paths.each { |x| doc["sources"].delete(x) }
  end
end
