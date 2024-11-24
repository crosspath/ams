# frozen_string_literal: true

# CLI command for showing Skap version.
module Skap::CLI::Version
  include Skap::Command
  extend self

  # @return [void]
  def start
    puts "Skap, v#{Skap::VERSION}"
  end
end
