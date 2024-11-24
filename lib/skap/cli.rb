# frozen_string_literal: true

require "English"
require "fileutils"
require "io/console"
require "psych"

require_relative "command"
require_relative "string_utils"
require_relative "yaml_file"

require_relative "files/menu"
require_relative "files/sources"
require_relative "files/versions"

# Dispatcher for CLI commands.
module Skap::CLI
  # @param argv [Array<String>]
  # @return [void]
  def self.start(argv = ARGV)
    section, command, *rest = argv

    case section
    when "help", "--help", "-h", nil then Skap::CLI::Help.start
    when "init" then Skap::CLI::Init.start(command, rest)
    when "sources" then Skap::CLI::Sources.start(command, rest)
    when "version", "--version", "-v" then Skap::CLI::Version.start
    when "works" then Skap::CLI::Works.start(command, rest)
    else
      raise ArgumentError, "Unknown section: #{section}"
    end
  end
end

# TODO: Command "clone" - it calls "git clone" & initializes git submodules.
# git clone --recurse <URL> <directory>

require_relative "cli/help"
require_relative "cli/init"
require_relative "cli/sources"
require_relative "cli/version"
require_relative "cli/works"
