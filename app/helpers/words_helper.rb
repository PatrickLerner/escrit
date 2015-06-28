module WordsHelper
  def self.raw_words text
    content = text.mb_chars.downcase.to_s
    content.scan /[^#{WordsHelper.seperators}]+[^ \n\t]*[^#{WordsHelper.seperators}]+|[^#{WordsHelper.seperators}]+/
  end

  def self.split_words text
    text.scan /[#{WordsHelper.seperators}]+|[^#{WordsHelper.seperators}]+[^ \n\t]*[^#{WordsHelper.seperators}]+|[^#{WordsHelper.seperators}]+/
  end

  def self.seperators
    " \/\\t\\.\\?!:,\\-–\#\\n\\r\\(\\)\\[\\]\\{\\}\"\*1234567890%><„,“;…«»—~”"
  end
end
