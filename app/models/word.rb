class Word < ActiveRecord::Base
  belongs_to :language
  belongs_to :user
  after_initialize :init

  def init
    self.rating ||= 0
  end

  def self.determine_replacement_value word, language_id
    v = word
    replacements = Replacement.where language_id: language_id
    replacements.each { |r|
      v = v.gsub r.value.downcase, r.replacement.downcase
      v = v.gsub r.value.upcase, r.replacement.upcase
    }
    v
  end

  def replacement_value
    Word.determine_replacement_value read_attribute(:value), read_attribute(:language_id)
  end

  def self.find_create language, word, user_id
    word = Word.determine_replacement_value word.mb_chars.downcase.to_s, language
    w = Word.find_by value: word, language: language, user_id: user_id
    w = Word.new value: word if not w
    return w
  end

  def self.find_create_bulk language, words, user_id
    words = words.map { |w|
      Word.determine_replacement_value w, language
    }
    remaining = words
    result = {}

    list = Word.where value: words, language: language, user_id: user_id
    list.each do |res|
      remaining.delete res.value
      word = res.value.mb_chars.downcase.to_s
      result[word] = res
    end

    remaining.each do |rem|
      word = rem.mb_chars.downcase.to_s
      result[word] = Word.new value: word, language: Language.find(language), user_id: user_id
    end

    return result
  end
end
