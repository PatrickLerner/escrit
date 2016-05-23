class Entry < ApplicationRecord
  belongs_to :word
  belongs_to :token

  validates :rating, numericality: { greater_than_or_equal_to: 0,
                                     less_than_or_equal_to: 5 }
  validates :word, presence: true
  validates :token, presence: true
  validates :token_id, uniqueness: { scope: :word_id }
end
