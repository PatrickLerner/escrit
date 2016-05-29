class Entry < ApplicationRecord
  belongs_to :word, inverse_of: :entries
  belongs_to :token, inverse_of: :entries

  validates :rating, numericality: { greater_than_or_equal_to: 0,
                                     less_than_or_equal_to: 5 }
  validates :word, presence: true
  validates :token, presence: true
  validates :token_id, uniqueness: { scope: :word_id }

  accepts_nested_attributes_for :word

  before_save :set_defaults

  protected

  def set_defaults
    self.rating ||= 0
  end
end
