class Word < ActiveRecord::Base
  belongs_to :language
  after_initialize :init

  def init
    self.rating ||= 0
  end

  def self.find_create language, word
    word = word.mb_chars.downcase.to_s
    w = Word.find_by value: word, language: language
    w = Word.new value: word if not w
    return w
  end

  def self.find_create_bulk language, words
    remaining = words
    result = {}

    list = Word.where value: words, language: language
    list.each do |res|
      remaining.delete res.origin
      word = res.origin.mb_chars.downcase.to_s
      result[word] = res
    end

    remaining.each do |rem|
      word = rem.mb_chars.downcase.to_s
      result[word] = Word.new value: word, language: Language.find(language)
    end

    return result
  end
end
