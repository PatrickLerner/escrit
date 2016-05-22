class Word < ApplicationRecord
  include NormalizedValued
  include TokenRelated

  searchkick

  has_and_belongs_to_many :tokens
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
