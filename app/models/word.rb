class Word < ActiveRecord::Base
  belongs_to :language
  belongs_to :user
  after_initialize :init

  def init
    self.rating ||= 0
  end

  def self.determine_replacement_value word, replacements
    v = word
    replacements.each { |r|
      v = v.gsub r.value.downcase, r.replacement.downcase
      v = v.gsub r.value.upcase, r.replacement.upcase
    }
    v
  end

  def replacement_value replacements
    Word.determine_replacement_value read_attribute(:value), replacements
  end

  def self.find_create language_id, word, user_id
    replacements = Replacement.where language_id: language_id
    word = Word.determine_replacement_value word.mb_chars.downcase.to_s, replacements
    w = Word.find_by value: word, language_id: language_id, user_id: user_id
    w = Word.new value: word if not w
    return w
  end

  def self.find_create_bulk language_id, words, user_id
    replacements = Replacement.where language_id: language_id
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = wparts[2].mb_chars.downcase.to_s
      end
      Word.determine_replacement_value w, replacements
    }.uniq
    remaining = words
    result = {}

    list = Word.where value: words, language_id: language_id, user_id: user_id
    list.each do |res|
      remaining.delete res.value
      word = res.value.mb_chars.downcase.to_s
      result[word] = res
    end

    remaining.each do |rem|
      word = rem.mb_chars.downcase.to_s
      result[word] = Word.new value: word, language_id: language_id, user_id: user_id
    end

    return result
  end
end
