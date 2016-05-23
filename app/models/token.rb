class Token < ApplicationRecord
  include NormalizedValued

  validates :value, uniqueness: true

  has_many :entries
  has_many :words, through: :entries
  has_and_belongs_to_many :texts

  # if a word is not referenced by anything, it should be deleted
  def destroy
    super if texts.count.zero? && words.count.zero?
  end
end
