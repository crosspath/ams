# frozen_string_literal: true

# Common class for CLI command.
module Skap::Command
  CURRENT_DIR = Dir.pwd.freeze

  private

  # @return [void]
  def assert_cwd
    raise "Current dir isn't a repo for sources" if !File.exist?(Skap::Files::Sources.file_name)
  end

  # @param args [Array<String>]
  # @return [void]
  def assert_empty_options(args)
    raise ArgumentError, "Unknown options: #{args.inspect}" if !args.empty?
  end

  # @param cmd [String]
  # @param dir [String]
  # @return [String]
  def shell(cmd, dir: "")
    dir = dir == "~" ? Dir.home : File.absolute_path(dir, CURRENT_DIR)
    `cd #{dir} && #{cmd}`.strip
  end
end
