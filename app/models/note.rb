class Note < ActiveRecord::Base
  using StringRefinements
  include Note::Vocabulary

  belongs_to :word
  belongs_to :user

  validates :rating, presence: true,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :user, presence: true
  validates :word, presence: true
  validates :word, uniqueness: { scope: :user_id }
  validates_uniqueness_of :word_id, scope: :user_id

  after_initialize :init

  def init
    self.rating ||= 0
    self.value ||= ''
  end

  def to_json
    {
      value: word.value,
      value_clean: word.value_clean,
      note: value.strip,
      language: word.language.name,
      rating: rating,
      vocabulary: vocabulary?
    }
  end

  def self.for(user, language)
    includes(:word).joins(:word).order('notes.created_at DESC')
                   .where('user_id = ? and rating < 6 and language_id = ?',
                          user.id, language.id)
  end

  def self.find_create(language, word, user)
    word = Word.determine_replacement_value word.utf8downcase, language
    notes = Note.joins(:word).where(
      'words.value = ? and words.language_id = ? and user_id = ?',
      word, language.id, user.id)
    if notes.empty?
      Note.new(value: '', word: Word.find_create(language, word), user: user)
    else
      notes[0]
    end
  end

  def self.find_create_bulk(language, words, user)
    words = words.map do |w|
      if w =~ /(.*)\|\|(.*)/
        wparts = w.match(/(.*)\|\|(.*)/)
        w = wparts[2].utf8downcase
      end
      Word.determine_replacement_value w, language
    end
    remaining = words.uniq
    result = {}

    list = Note.includes(:word).joins(:word).where(
      'words.value in (?) and words.language_id = ? and user_id = ?',
      words, language.id, user.id)
    list.each do |res|
      remaining.delete res.word.value
      word = res.word.value.utf8downcase
      result[word] = res
    end

    remaining_words = Word.find_create_bulk language, remaining
    remaining.each do |rem|
      word = rem.utf8downcase
      result[word] = Note.new value: '', word: remaining_words[word], user: user
    end

    result
  end
end
