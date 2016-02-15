module Note::Vocabulary
  extend ActiveSupport::Concern

  included do
    before_save :check_vocab_set

    VOCAB_REVIEW_INTERVALS = [
      VOCAB_REVIEW_INTERVAL_0 = 2,
      VOCAB_REVIEW_INTERVAL_1 = 3,
      VOCAB_REVIEW_INTERVAL_2 = 5,
      VOCAB_REVIEW_INTERVAL_3 = 7,
      VOCAB_REVIEW_INTERVAL_4 = 13,
      VOCAB_REVIEW_INTERVAL_5 = 31
    ].freeze
  end

  def self.included(including_class)
    including_class.extend ClassMethods
  end

  module ClassMethods
    def vocabulary_for_review(user, language)
      Note.includes(:word).joins(:word).where(
        'notes.user_id = ? AND words.language_id = ? AND ' \
        'vocabulary = TRUE AND rating < 6 AND notes.review_at < ?',
        user.id, language.id, DateTime.now
      ).order(:review_at)
    end

    def vocabulary(user, language)
      Note.includes(:word).joins(:word).where(
        'notes.user_id = ? AND words.language_id = ? AND ' \
        'vocabulary = TRUE AND rating < 6', user.id, language.id)
    end

    def sample_vocabulary(user, language)
      Note.joins(:word).where(
        'words.language_id = ? AND user_id = ? AND vocabulary = true',
        language.id, user.id
      ).order('RANDOM()').first
    end

    def shuffle_vocabulary!(user, language)
      # 50 words first day, -10 after to a minimum of 10
      max_words = 50
      days_plus = 0
      vocab = Note.vocabulary user, language
      while vocab.count > 0
        selected = vocab.sample(max_words)
        Note.where(id: selected.map(&:id))
            .update_all(review_at: days_plus.days.since)
        vocab -= selected

        days_plus += 1
        max_words -= 10 if max_words > 10
      end
    end
  end

  def vocabulary?
    vocabulary
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
