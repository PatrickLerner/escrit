module WordsHelper
  # Just extract the words from a text
  def self.raw_words text
    content = ApplicationController.utf8downcase text
    content.scan(Text::WORD_REGEX)
  end
end
