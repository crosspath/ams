# frozen_string_literal: true

module Skap
  module CLI::Help
    include Command
    extend self

    # @return [void]
    def start
      menu = Files::Menu.new
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

    private

    # @param paragraph [String]
    # @param max_width [Integer]
    # @return [Array<String>]
    def break_words(paragraph, max_width)
      words = paragraph.split
      parts = [[]]
      line_width = 0

      while !words.empty?
        word_size = words.first.size
        is_line_empty = line_width == 0
        new_line_width = (is_line_empty ? line_width : line_width + 1) + word_size

        if new_line_width <= max_width
          parts.last << words.shift

          if new_line_width == max_width
            parts << []
            line_width = 0
          else
            line_width = new_line_width
          end
        else
          parts << [words.shift]
          line_width = word_size
        end
      end

      parts.pop if parts.last.empty?

      parts.map { |line| line.join(" ") }
    end

    # @param text [String]
    # @param indent [String]
    # @param max_width [Integer]
    # @return [void]
    def output_menu_item_text(text, indent, max_width)
      if text.is_a?(Array)
        text.each do |paragraph|
          break_words(paragraph, max_width).each { |line| puts "#{indent}#{line}" }
        end
      else
        break_words(text, max_width).each { |line| puts "#{indent}#{line}" }
      end
    end
  end
end
