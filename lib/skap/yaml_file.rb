# frozen_string_literal: true

module Skap
  class YAMLFile
    class << self
      attr_accessor :file_name

      private :file_name=
    end

    def initialize
      @file = load_file
    end

    private

    attr_reader :file

    # @return [Hash<String, Object>]
    def load_file
      Psych.load_file(self.class.file_name, symbolize_names: false) || {}
    end

    # @return [void]
    def update_file
      File.write(self.class.file_name, Psych.dump(file, line_width: 100))
    end
  end
end
