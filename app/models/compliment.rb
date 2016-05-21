class Compliment < ApplicationRecord
  belongs_to :language

  validates :value, length: { minimum: 3 }
  validates :language_id, presence: true

  default_scope { joins(:language).order('languages.name asc, value asc') }
end
