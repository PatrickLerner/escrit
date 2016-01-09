class Note < ActiveRecord::Base
  belongs_to :word
  belongs_to :user

  after_initialize :init
  before_save :check_vocab_set

  VOCAB_REVIEW_INTERVAL_0 = 2
  VOCAB_REVIEW_INTERVAL_1 = 3
  VOCAB_REVIEW_INTERVAL_2 = 5
  VOCAB_REVIEW_INTERVAL_3 = 7
  VOCAB_REVIEW_INTERVAL_4 = 13
  VOCAB_REVIEW_INTERVAL_5 = 31

  def init
    self.rating ||= 0
  end

  def vocabulary?
    self.vocabulary == true
  end

  def update_review_at!
    next_review = DateTime.now

    next_review += VOCAB_REVIEW_INTERVAL_0.days if self.rating == 0
    next_review += VOCAB_REVIEW_INTERVAL_1.days if self.rating == 1
    next_review += VOCAB_REVIEW_INTERVAL_2.days if self.rating == 2
    next_review += VOCAB_REVIEW_INTERVAL_3.days if self.rating == 3
    next_review += VOCAB_REVIEW_INTERVAL_4.days if self.rating == 4
    next_review += VOCAB_REVIEW_INTERVAL_5.days if self.rating == 5

    self.update_column('review_at', next_review)
  end

  def self.vocabulary_for_review user, language
    Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6 AND notes.review_at < ?', user.id, language.id, DateTime.now)
  end

  def check_vocab_set
    if self.vocabulary_changed?
      update_review_at!
    end
  end

  def self.find_create language, word, user
    word = Word.determine_replacement_value ApplicationController.utf8downcase(word), language
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
        w = ApplicationController.utf8downcase wparts[2]
      end
      Word.determine_replacement_value w, language
    }.uniq
    remaining = words
    result = {}

    list = Note.includes(:word).joins(:word).where('words.value in (?) and words.language_id = ? and user_id = ?', words, language.id, user.id)
    list.each do |res|
      remaining.delete res.word.value
      word = ApplicationController.utf8downcase res.word.value
      result[word] = res
    end

    remaining_words = Word.find_create_bulk language, remaining
    remaining.each do |rem|
      word = ApplicationController.utf8downcase rem
      result[word] = Note.new value: '', word: remaining_words[word], user: user
    end

    return result
  end
end
