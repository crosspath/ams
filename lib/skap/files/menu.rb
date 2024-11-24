# frozen_string_literal: true

require "forwardable"

# Class for file "menu.yaml" (this file is part of Skap).
class Skap::Files::Menu < Skap::YAMLFile
  extend Forwardable

  SKAP_DIR = File.expand_path("../../..", __dir__).freeze

  self.file_name = File.join(SKAP_DIR, "menu.yaml")

  def_delegators :file, :each
end
