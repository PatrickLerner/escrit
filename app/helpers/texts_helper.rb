module TextsHelper
  using StringRefinements

  def process_token_value(value)
    value.utf8downcase.gsub(/.*?\|\|(.*)$/, '\1')
  end

  # a helper to compensate for the piss-poor unicode capabilities of js.
  # Returns all words that occur in a text split into an array.
  def js_split_tokens(text)
    words = "#{text.title} #{text.content}".scan(Tokenizable::WORD_REGEX)
    words = words.uniq.sort_by(&:length).reverse
    words = words.select { |w| !w.match NormalizedValued::URL_REGEX }
    Hash[words.collect { |w| [w, process_token_value(w)] }]
  end
end
