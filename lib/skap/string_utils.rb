# frozen_string_literal: true

# Manipulations with strings.
module Skap::StringUtils
  extend self

  # @param paragraph [String]
  # @param max_width [Integer]
  # @return [Array<String>]
  def break_by_words(paragraph, max_width)
    words = paragraph.split
    parts = [[]]
    line_width = 0

    while !words.empty?
      word = words.shift
      new_line_width = (line_width == 0 ? line_width : line_width + 1) + word.size
      line_width = add_word(word, parts, new_line_width, max_width)
    end

    parts.pop if parts.last.empty?

    parts.map { |line| line.join(" ") }
  end

  private

  # @param word [String]
  # @param parts [Array<String>]
  # @param new_line_width [Integer]
  # @param max_width [Integer]
  # @return [Integer] Current line width
  def add_word(word, parts, new_line_width, max_width) # rubocop:disable Metrics/MethodLength
    if new_line_width <= max_width
      parts.last << word

      if new_line_width == max_width
        parts << []
        0
      else
        new_line_width
      end
    else
      parts << [word]
      word.size
    end
  end
end
