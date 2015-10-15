module WordsHelper
  # Just extract the words from a text
  def self.raw_words text
    content = text.mb_chars.downcase.to_s
    content.scan(/[^#{WordsHelper.seperators}]+[^ \n\t]*[^#{WordsHelper.seperators}]+|[^#{WordsHelper.seperators}]+/)
  end

  # split a text up into words and non-words (seperator chains)
  def self.split_words text
    text.scan(/[#{WordsHelper.seperators}]+|[^#{WordsHelper.seperators}]+[^ \n\t]*[^#{WordsHelper.seperators}]+[0-9]*|[^#{WordsHelper.seperators}]+/)
  end

  def self.seperators
    "  −\/\\t\\.\\?!:,\\-–\#\\n\\r\\(\\)\\[\\]\|\\{\\}\"\*+1234567890%><&=„,°“;…«»—~”'_\$"
  end
end
