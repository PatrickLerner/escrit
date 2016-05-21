class Language < ApplicationRecord
  has_many :compliments
  has_many :replacements
  has_many :texts
  has_many :words

  param_field :code

  validates :name, uniqueness: true, length: { minimum: 3 }
  validates :code, uniqueness: true, length: { is: 2 },
                   format: { with: /[a-z]{2}/, message: :lowercase_latin }

  scope :with_text_counts, lambda { |user|
    joins('LEFT JOIN texts ON texts.language_id = languages.id')
      .group('languages.id')
      .select('languages.*, COUNT(texts.id) AS text_count')
      .where('texts.user_id = ? OR texts.id IS NULL', user.id)
  }
end
