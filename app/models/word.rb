class Word < ApplicationRecord
  include NormalizedValued
  include TokenRelated

  searchkick

  has_many :entries, inverse_of: :word, dependent: :destroy
  has_many :notes
  has_many :tokens, through: :entries
  belongs_to :language
  belongs_to :user

  validates :value, uniqueness: { scope: [:language_id, :user_id] }
  validates :language, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :notes, reject_if: :all_blank

  before_validation :combine_words, if: :similar_word?

  scope :search_import, lambda {
    includes(:language).includes(:tokens).includes(:notes)
  }

  def search_data
    as_json(only: search_data_attributes).merge(
      tokens: all_tokens,
      notes: all_notes,
      language: language.try(:code)
    )
  end

  def search_data_attributes
    [:value, :user_id]
  end

  protected

  def all_tokens
    tokens.loaded? ? tokens.map(&:value) : tokens.pluck(:value)
  end

  def all_notes
    notes.loaded? ? notes.map(&:value) : notes.pluck(:value)
  end

  def similar_word?
    similar_word.present?
  end

  def similar_word
    @similar_word = nil if changed?
    @similar_word ||= Word.where(
      value: value, user_id: user_id, language_id: language_id
    ).where.not(id: id).first
    @similar_word
  end

  # combine words if they have the same value, user and language
  def combine_words
    migrate_attribute(:notes, from: similar_word, unique: :value)
    migrate_attribute(:entries, from: similar_word, unique: :token_id)
    similar_word.destroy!
  end

  def migrate_attribute(what, from: self, to: self, unique: nil)
    from.method(what).call.each do |attr|
      attr.word_id = to.id
      check_uniqueness_and_save(what, attr, to: to, unique: unique)
    end
  end

  def check_uniqueness_and_save(what, attr, to: self, unique: nil)
    attr_val = attr.method(unique).call
    already_exists = to.method(what).call.pluck(unique).include?(attr_val)
    return attr.destroy if already_exists
    attr.save!
  end
end
