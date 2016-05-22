module TextsHelper
  # a helper to compensate for the piss-poor unicode capabilities of js.
  # Returns all words that occur in a text split into an array.
  def js_split_tokens(text)
    words = "#{text.title} #{text.content}".scan(Tokenizable::WORD_REGEX)
    words = words.uniq.sort_by(&:length).reverse
    Hash[words.collect { |w| [w, w.mb_chars.downcase.to_s] }]
  end
end
