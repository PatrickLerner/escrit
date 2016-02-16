class Note < ActiveRecord::Base
  using StringRefinements

  belongs_to :word
  belongs_to :user

  validates :rating, presence: true, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :user, presence: true
  validates :word, presence: true
  validates :word, uniqueness: { scope: :user_id }
  validates_uniqueness_of :word_id, scope: :user_id

  after_initialize :init
  before_save :check_vocab_set

  scope :for_user, ->(user) { where(user: user) }
  scope :vocabulary, -> { where(vocabulary: true) }

  VOCAB_REVIEW_INTERVALS = [
    VOCAB_REVIEW_INTERVAL_0 = 2,
    VOCAB_REVIEW_INTERVAL_1 = 3,
    VOCAB_REVIEW_INTERVAL_2 = 5,
    VOCAB_REVIEW_INTERVAL_3 = 7,
    VOCAB_REVIEW_INTERVAL_4 = 13,
    VOCAB_REVIEW_INTERVAL_5 = 31
  ].freeze

  def self.for_language(language)
    joins(:word).where('words.language_id = ?', language.id)
  end

  def self.reset_all
    update_all(vocabulary: false)
  end

  def self.awaiting_review
    where('rating < 6 AND notes.review_at < ?', DateTime.now)
      .order(:review_at)
  end

  def self.sample_vocabulary(user, language)
    Note.joins(:word).where(
      'words.language_id = ? AND user_id = ? AND vocabulary = true',
      language.id, user.id
    ).order('RANDOM()').first
  end

  def self.shuffle_vocabulary!(user, language)
    # 50 words first day, -10 after to a minimum of 10
    max_words = 50
    days_plus = 0
    vocab = Note.vocabulary.for_user(user).for_language(language)
    while vocab.count > 0
      selected = vocab.sample(max_words)
      Note.where(id: selected.map(&:id))
          .update_all(review_at: days_plus.days.since)
      vocab -= selected

      days_plus += 1
      max_words -= 10 if max_words > 10
    end
  end

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

  def vocabulary?
    vocabulary
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

  def update_review_at!
    next_review = DateTime.now
    next_review += Note::VOCAB_REVIEW_INTERVALS[rating]
    update_column('review_at', next_review)
  end

  private

  def check_vocab_set
    update_review_at! if vocabulary_changed? && persisted?
  end
end
