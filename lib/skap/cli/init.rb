# frozen_string_literal: true

module Skap
  module CLI::Init
    include Command
    extend self

    # @param dir [String]
    # @param args [Array<String>]
    # @return [void]
    def start(dir, args)
      assert_empty_options(args)

      FileUtils.mkdir_p(dir)

      shell("git init", dir:)
      shell("echo '---\n' > #{Files::Sources.file_name}", dir:)
      shell("echo '---\n' > #{Files::Versions.file_name}", dir:)

      puts "Git repo initialized in #{dir}"
    end
  end
end
