class Token < ApplicationRecord
  include NormalizedValued

  validates :value, uniqueness: true

  has_many :entries, inverse_of: :token
  has_many :words, through: :entries
  has_and_belongs_to_many :texts

  accepts_nested_attributes_for :entries

  # if a word is not referenced by anything, it should be deleted
  def destroy
    super if texts.count.zero? && words.count.zero?
  end

  def words_for_user(user)
    Word.search '*', where: {
      tokens: value,
      user_id: user.id
    }
  end
end
