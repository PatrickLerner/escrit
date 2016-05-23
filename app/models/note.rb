class Note < ApplicationRecord
  belongs_to :word

  validates :word, presence: true
  validates :value, uniqueness: { scope: [:word_id] }, length: { minimum: 1 }
end
