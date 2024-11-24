# frozen_string_literal: true

# CLI command for repository initialization.
module Skap::CLI::Init
  include Skap::Command
  extend self

  # @param dir [String]
  # @param args [Array<String>]
  # @return [void]
  def start(dir, args)
    assert_empty_options(args)

    FileUtils.mkdir_p(dir)

    shell("git init", dir:)
    shell("echo '---\n' > #{Skap::Files::Sources.file_name}", dir:)
    shell("echo '---\n' > #{Skap::Files::Versions.file_name}", dir:)

    puts "Git repo initialized in #{dir}"
  end
end
