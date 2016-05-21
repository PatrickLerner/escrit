class Word < ApplicationRecord
  include NormalizedValued
  include TokenRelated

  searchkick

  has_and_belongs_to_many :tokens
  belongs_to :language
  belongs_to :user

  validates :value, uniqueness: { scope: [:language_id, :user_id] }

  def search_data
    {
      value: value,
      language: language.try(:code),
      tokens: tokens.pluck(:value)
    }
  end
end
