class Note < ActiveRecord::Base
  using StringRefinements
  
  belongs_to :word
  belongs_to :user

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :user, presence: true
  validates :word, presence: true
  validates :word, uniqueness: { scope: :user_id }
  validates_uniqueness_of :word_id, scope: :user_id

  after_initialize :init
  before_save :check_vocab_set

  VOCAB_REVIEW_INTERVALS = [
    VOCAB_REVIEW_INTERVAL_0 = 2,
    VOCAB_REVIEW_INTERVAL_1 = 3,
    VOCAB_REVIEW_INTERVAL_2 = 5,
    VOCAB_REVIEW_INTERVAL_3 = 7,
    VOCAB_REVIEW_INTERVAL_4 = 13,
    VOCAB_REVIEW_INTERVAL_5 = 31,
  ]

  def init
    self.rating ||= 0
    self.value ||= ''
  end

  def vocabulary?
    self.vocabulary
  end

  def update_review_at!
    next_review = DateTime.now

    next_review += VOCAB_REVIEW_INTERVALS[self.rating]

    self.update_column('review_at', next_review)
  end

  def self.vocabulary_for_review user, language
    Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6 AND notes.review_at < ?', user.id, language.id, DateTime.now).order(:review_at)
  end

  def self.vocabulary_for_review_count user, language
    Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6 AND notes.review_at < ?', user.id, language.id, DateTime.now).count
  end

  def self.vocabulary user, language
    Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6', user.id, language.id)
  end

  def self.vocabulary_count user, language
    Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6', user.id, language.id).count
  end

  def self.shuffle_vocabulary! user, language
    # 50 words first day, -10 after to a minimum of 10
    max_words = 50
    days_plus = 0
    vocab = Note.vocabulary user, language
    while vocab.count > 0
      selected = vocab.sample(max_words)
      Note.where(id: selected.map(&:id)).update_all(review_at: days_plus.days.since)
      vocab -= selected

      days_plus += 1
      max_words -= 10 if max_words > 10
    end
  end

  def check_vocab_set
    if self.vocabulary_changed? and self.persisted?
      update_review_at!
    end
  end

  def self.find_create language, word, user
    word = Word.determine_replacement_value word.utf8downcase, language
    w = Note.joins(:word).where('words.value = ? and words.language_id = ? and user_id = ?', word, language.id, user.id)
    if w.length == 0
      w = [Note.new(value: '', word: Word.find_create(language, word), user: user)]
    end
    return w[0]
  end

  def self.find_create_bulk language, words, user
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = wparts[2].utf8downcase
      end
      Word.determine_replacement_value w, language
    }.uniq
    remaining = words
    result = {}

    list = Note.includes(:word).joins(:word).where('words.value in (?) and words.language_id = ? and user_id = ?', words, language.id, user.id)
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

    return result
  end
end
