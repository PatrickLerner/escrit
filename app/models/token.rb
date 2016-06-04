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

  def parse_update(params, current_user)
    params[:words].each do |data|
      word_reference(data, current_user).parse_update(data, current_user)
    end
    remove_old_word_references(params)
    save!
  end

  protected

  def remove_old_word_references(params)
    new_lst = params[:words].map { |w| w[:value] }
    words.each do |word|
      entries.where(word: word).destroy_all unless word.value.in?(new_lst)
    end
  end

  def word_reference(params, current_user)
    word = words.find_or_initialize_by(value: params[:to_param],
                                       language_id: params[:language_id],
                                       user_id: current_user.id)
    entries.build(word: word) unless entries.where(word_id: word.id)
    word
  end
end
