class Language < ApplicationRecord
  has_many :compliments
  has_many :replacements
  has_many :texts
  has_many :words

  param_field :code

  validates :name, uniqueness: true, length: { minimum: 3 }
  validates :code, uniqueness: true, length: { is: 2 },
                   format: { with: /[a-z]{2}/, message: :lowercase_latin }
end
