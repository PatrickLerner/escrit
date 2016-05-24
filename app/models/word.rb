class Word < ApplicationRecord
  include NormalizedValued
  include TokenRelated

  searchkick

  has_many :entries, dependent: :destroy
  has_many :notes
  has_many :tokens, through: :entries
  belongs_to :language
  belongs_to :user

  validates :value, uniqueness: { scope: [:language_id, :user_id] }
  validates :language, presence: true
  validates :user, presence: true

  scope :search_import, lambda {
    includes(:language).includes(:tokens).includes(:notes)
  }

  def search_data
    {
      value: value,
      language: language.try(:code),
      tokens: all_tokens,
      notes: all_notes
    }
  end

  protected

  def all_tokens
    tokens.loaded? ? tokens.map(&:value) : tokens.pluck(:value)
  end

  def all_notes
    notes.loaded? ? notes.map(&:value) : notes.pluck(:value)
  end
end
