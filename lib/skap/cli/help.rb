# frozen_string_literal: true

# CLI command with help message.
module Skap::CLI::Help
  include Skap::Command
  extend self

  # @return [void]
  def start
    menu = Skap::Files::Menu.new

    puts "Usage:", ""

    show_menu(menu, $DEFAULT_OUTPUT.winsize.last)
  end

  private

  # @param text [String]
  # @param indent [String]
  # @param max_width [Integer]
  # @return [void]
  def output_menu_item_text(text, indent, max_width)
    res = []

    if text.is_a?(Array)
      text.each { |paragraph| res += Skap::StringUtils.break_by_words(paragraph, max_width) }
    else
      res += Skap::StringUtils.break_by_words(text, max_width)
    end

    res.each { |line| puts "#{indent}#{line}" }
  end

  # @param menu [Files::Menu]
  # @param width [Integer]
  # @return [void]
  def show_menu(menu, width) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    section_indent = " " * 4
    command_indent = " " * 8
    within_section = width - 4
    within_command = width - 8

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
