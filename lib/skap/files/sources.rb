# frozen_string_literal: true

# Class for file "sources.yaml" (this file describes sources in project repository).
class Skap::Files::Sources < Skap::YAMLFile
  self.file_name = "sources.yaml"

  # @param dir [String]
  # @return [void]
  def add_source(dir)
    file[dir] = {"file-extensions" => [], "ignored" => [], "indexed" => []}
    @file = file.sort_by(&:first).to_h

    update_file
  end

  # @param dir [String]
  # @return [void]
  def delete_source(dir)
    file.delete(dir)
    update_file
  end

  # @param key [String]
  # @param dirs [Array<String>]
  # @return [Hash<String, Array<String>>]
  def extract(key, dirs = [])
    sources = dirs.empty? ? file : file.slice(*dirs)
    sources
      .transform_values { |v| v[key] }
      .reject { |_, v| v.nil? || v.empty? }
  end

  # @param dirs [Array<String>]
  # @return [Hash<String, Hash<String, Array<String>>>]
  def select_directories!(dirs)
    @file = file.slice(*dirs)
  end
end
