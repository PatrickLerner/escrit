class Word < ActiveRecord::Base
  belongs_to :language
  belongs_to :user
  has_many :notes
  has_many :occurrences

  def self.determine_replacement_value word, language_id
    replacements = Replacement.for_language language_id
    v = word
    replacements.each { |r|
      v = v.gsub r.value.downcase, r.replacement.downcase
      v = v.gsub r.value.upcase, r.replacement.upcase
    }
    v
  end

  def replacement_value
    Word.determine_replacement_value self.value, self.language_id
  end

  def self.find_create language_id, word
    word = Word.determine_replacement_value ApplicationController.utf8downcase(word), language_id
    w = Word.find_by value: word, language_id: language_id
    w = Word.new value: word, language_id: language_id if not w
    return w
  end

  def self.find_create_bulk language_id, words
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = ApplicationController.utf8downcase wparts[2]
      end
      Word.determine_replacement_value w, language_id
    }.uniq
    remaining = words
    result = {}

    list = Word.where value: words, language_id: language_id
    list.each do |res|
      remaining.delete res.value
      word = ApplicationController.utf8downcase res.value
      result[word] = res
    end

    remaining.each do |rem|
      word = ApplicationController.utf8downcase rem
      result[word] = Word.new value: word, language_id: language_id
    end

    return result
  end
end
