# frozen_string_literal: true

require "forwardable"

module Skap
  module Files
    class Menu < YAMLFile
      extend Forwardable

      SKAP_DIR = File.expand_path("../../..", __dir__).freeze

      self.file_name = File.join(SKAP_DIR, "menu.yaml")

      def_delegators :file, :each
    end
  end
end
