class Compliment < ActiveRecord::Base
  belongs_to :language
  validates :value, length: { minimum: 3 }
  validates :language_id, presence: true
end
