module Tokenizable
  using StringRefinements
  extend ActiveSupport::Concern

  WORD_REGEX = %r{                # either it
    \p{Alpha}                     #   starts with alpha
    [\p{Alpha}\-\|\.:\/\?=0-9%_]+ #   continues with alpha, num or special
    [\p{Alpha}0-9]                #   and finally ends in alpha
    |                             # or alternatively
    \p{Alpha}+                    #   it is only alpha, even just one letter
  }ix

  def self.included(base)
    base.before_save :create_words
  end

  protected

  def create_words
    new_words = tokens_in_text
    obsolte = tokens.select { |w| !w.in?(new_words) }
    self.tokens = new_words
    obsolte.each(&:destroy)
  end

  def tokens_in_text
    raw_tokens = raw_tokens_in_text
    existing_tokens = existing_tokens_in_text(raw_tokens)
    existing_tokens + new_tokens_in_text(raw_tokens, existing_tokens)
  end

  def new_tokens_in_text(raw_tokens, existing_tokens)
    tokens = remaining_tokens_in_text(raw_tokens, existing_tokens)
    Token.transaction do
      tokens.each(&:save!)
    end
    tokens
  end

  def remaining_tokens_in_text(raw_tokens, existing_tokens)
    values = raw_tokens - existing_tokens.map(&:value)
    values.map do |value|
      Token.new(value: value)
    end
  end

  def existing_tokens_in_text(raw_tokens)
    Token.where(value: raw_tokens)
  end

  def raw_tokens_in_text
    words = raw_text.scan(WORD_REGEX)
    words.select! { |w| !w.match NormalizedValued::URL_REGEX }
    words.map! { |v| v.gsub(/.*?\|\|(.*)$/, '\1') }
    words.map! { |v| v.utf8downcase.to_s }
    words.uniq.sort
  end

  def raw_text
    fields = self.class.tokenized_fields.map do |field|
      method(field).call
    end
    fields.join(' ')
  end

  class_methods do
    def tokenized_fields(*fields)
      @tokenized_fields ||= fields unless fields.length.zero?
      @tokenized_fields
    end
  end
end
