# frozen_string_literal: true

require "English"
require "fileutils"
require "io/console"
require "psych"

require_relative "command"
require_relative "yaml_file"

require_relative "files/menu"
require_relative "files/sources"
require_relative "files/versions"

module Skap
  module CLI
    # @param argv [Array<String>]
    # @return [void]
    def self.start(argv = ARGV)
      section, command, *rest = argv

      case section
      when "works" then CLI::Works.start(command, rest)
      when "help", "--help", "-h", nil then CLI::Help.start
      when "init" then CLI::Init.start(command, rest)
      when "sources" then CLI::Sources.start(command, rest)
      else
        raise ArgumentError, "Unknown section: #{section}"
      end
    end
  end
end

# TODO: Command "clone" - it calls "git clone" & initializes git submodules.
# git clone --recurse <URL> <directory>

require_relative "cli/help"
require_relative "cli/init"
require_relative "cli/sources"
require_relative "cli/works"
