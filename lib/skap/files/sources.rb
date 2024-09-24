# frozen_string_literal: true

module Skap
  module Files
    class Sources < YAMLFile
      self.file_name = "sources.yaml"

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
  end
end
