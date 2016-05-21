class Token < ApplicationRecord
  include NormalizedValued

  validates :value, uniqueness: true

  has_and_belongs_to_many :texts
  has_and_belongs_to_many :words

  # if a word is not referenced by anything, it should be deleted
  def destroy
    super if texts.count.zero? && words.count.zero?
  end
end
