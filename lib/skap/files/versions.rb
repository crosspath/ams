# frozen_string_literal: true

# Class for file "versions.yaml" (this file describes versions of works in project repository).
class Skap::Files::Versions < Skap::YAMLFile
  self.file_name = "versions.yaml"

  # @param document_path [String]
  # @param document [Hash<String, Object>]
  # @return [void]
  def add_document(document_path, document)
    file[document_path] = document
    @file = file.sort_by(&:first).to_h

    update_file
  end

  # @return [Set<String>]
  def covered_sources
    result = Set.new

    file.each_value { |value| result.merge(value["sources"].keys) }

    result
  end

  # @param document_path [String]
  # @return [Hash<String, Object>]
  def find_document(document_path)
    file[document_path]
  end

  # @return [Array<Array(String, Array<String>)>]
  def outdated_documents
    sources_sha = {}

    file.filter_map do |doc_path, hash|
      outdated_sources =
        hash["sources"].filter_map do |source_path, source_data|
          sha = (sources_sha[source_path] ||= yield(source_path))
          source_path if !sha.nil? && sha != source_data["sha"]
        end
      [doc_path, outdated_sources] if !outdated_sources.empty?
    end
  end
end
