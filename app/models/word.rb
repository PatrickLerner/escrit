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

  scope :search_import, -> { includes(:language).includes(:tokens) }

  def search_data
    {
      value: value,
      language: language.try(:code),
      tokens: tokens.loaded? ? tokens.map(&:value) : tokens.pluck(:value)
    }
  end
end
