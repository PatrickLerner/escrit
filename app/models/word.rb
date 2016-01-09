class Word < ActiveRecord::Base
  belongs_to :language
  belongs_to :user
  has_many :notes
  has_many :occurrences

  validates :value, presence: true
  validates :language, presence: true
  validates :value, uniqueness: { scope: :language_id }

  def self.determine_replacement_value word, language
    replacements = language.replacements
    v = word
    replacements.each { |r|
      v = v.gsub r.value.downcase, r.replacement.downcase
      v = v.gsub r.value.upcase, r.replacement.upcase
    }
    v
  end

  def replacement_value
    Word.determine_replacement_value self.value, self.language
  end

  def value_clean
    val = self.value
    val = val.gsub '..', ' ... '
    val = val.gsub '...', ' ... '
    val = val.gsub '_', ' '
  end

  def self.find_create language, word
    word = Word.determine_replacement_value ApplicationController.utf8downcase(word), language
    w = Word.find_by value: word, language: language
    w = Word.new value: word, language: language if not w
    return w
  end

  def self.find_create_bulk language, words
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = ApplicationController.utf8downcase wparts[2]
      end
      Word.determine_replacement_value w, language
    }.uniq
    remaining = words
    result = {}

    list = Word.where value: words, language: language
    list.each do |res|
      remaining.delete res.value
      word = ApplicationController.utf8downcase res.value
      result[word] = res
    end

    remaining.each do |rem|
      word = ApplicationController.utf8downcase rem
      result[word] = Word.new value: word, language: language
    end

    return result
  end
end
