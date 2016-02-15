class Word < ActiveRecord::Base
  using StringRefinements

  belongs_to :language
  belongs_to :user
  has_many :notes
  has_many :occurrences

  validates :value, presence: true
  validates :language, presence: true
  validates :value, uniqueness: { scope: :language_id }

  def self.determine_replacement_value(word, language)
    replacements = language.replacements
    v = word
    replacements.each do |r|
      v = v.gsub r.value.downcase, r.replacement.downcase
      v = v.gsub r.value.upcase, r.replacement.upcase
    end
    v
  end

  def replacement_value
    Word.determine_replacement_value value, language
  end

  def value_clean
    val = value
    val = val.gsub '..', ' ... '
    val = val.gsub '...', ' ... '
    val.tr '_', ' '
  end

  def self.find_create(language, word)
    value = Word.determine_replacement_value word.utf8downcase, language
    word = Word.find_by value: value, language: language
    word ||= Word.new value: value, language: language
    word
  end

  def self.find_create_bulk(language, words)
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = wparts[2].utf8downcase
      end
      Word.determine_replacement_value w, language
    }.uniq
    remaining = words
    result = {}

    list = Word.where value: words, language: language
    list.each do |res|
      remaining.delete res.value
      word = res.value.utf8downcase
      result[word] = res
    end

    remaining.each do |rem|
      word = rem.utf8downcase
      result[word] = Word.new value: word, language: language
    end

    result
  end
end
