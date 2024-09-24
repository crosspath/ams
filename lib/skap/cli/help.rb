# frozen_string_literal: true

module Skap
  module CLI::Help
    include Command
    extend self

    # @return [void]
    def start
      menu = load_file(File.join(SKAP_DIR, MENU))
      width = $DEFAULT_OUTPUT.winsize.last
      section_indent = " " * 4
      command_indent = " " * 8
      within_section = width - 4
      within_command = width - 8

      puts "Usage:", ""

      menu.each do |item|
        puts item["cmd"]

        output_menu_item_text(item["text"], section_indent, within_section) if item.key?("text")

        next unless item.key?("children")

        item["children"].each do |subitem|
          [*subitem["cmd"]].each { |cmd| puts "#{section_indent}#{cmd}" }

          output_menu_item_text(subitem["text"], command_indent, within_command)
        end
      end
    end
  end
end
