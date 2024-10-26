# frozen_string_literal: true

module Skap
  module CLI::Version
    include Command
    extend self

    # @return [void]
    def start
      puts "Skap, v#{Skap::VERSION}"
    end
  end
end
