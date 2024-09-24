# frozen_string_literal: true

module Skap
  module CLI::Sources
    include Command
    extend self

    # @param command [String]
    # @param args [Array<String>]
    # @return [void]
    def start(command, args)
      assert_cwd

      case command
      when "add" then add(*args)
      when "delete" then delete(*args)
      when "update" then update(*args)
      else
        raise ArgumentError, "Unknown command: #{command}"
      end
    end

    private

    # @param dir [String]
    # @param repo [String]
    # @param branch [String]
    # @param rest [Array<String>]
    # @return [void]
    def add(dir, repo, branch, *rest)
      assert_empty_options(rest)

      return unless shell("git submodule add -b #{branch} --depth 3 -- #{repo} #{dir}")

      sources_data = load_file(SOURCES)
      sources_data[dir] = {"file-extensions" => [], "ignored" => [], "indexed" => []}

      sources_data = sources_data.sort_by(&:first).to_h
      File.write(SOURCES, Psych.dump(sources_data, line_width: 100))
    end

    # @param dir [String]
    # @param rest [Array<String>]
    # @return [void]
    def delete(dir, *rest)
      assert_empty_options(rest)

      shell("git submodule deinit -f -- #{dir} && git rm -f #{dir} && rm -rf .git/modules/#{dir}")
    end

    # @param dirs [Array<String>]
    # @return [void]
    def update(*dirs)
      path_arg = dirs.empty? ? "" : "-- #{dirs.join(" ")}"

      shell("git submodule update --checkout --single-branch --recursive #{path_arg}")
    end
  end
end
