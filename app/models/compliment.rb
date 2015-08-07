class Compliment < ActiveRecord::Base
  belongs_to :language
  default_scope { joins(:language).order('languages.name asc, value asc') }
  validates :value, length: { minimum: 3 }
  validates :language_id, presence: true
end
