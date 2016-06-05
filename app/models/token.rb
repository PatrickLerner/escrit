class Token < ApplicationRecord
  include NormalizedValued

  validates :value, uniqueness: true

  has_many :entries, inverse_of: :token
  has_many :words, through: :entries
  has_and_belongs_to_many :texts

  accepts_nested_attributes_for :entries

  after_save :reindex_words

  # if a word is not referenced by anything, it should be deleted
  def destroy
    super if texts.count.zero? && words.count.zero?
  end

  def words_for_user(user)
    words.owned_by(user)
  end

  def parse_update(params, current_user)
    params[:words].each do |data|
      word_reference(data, current_user).parse_update(data, current_user)
    end
    remove_old_word_references(params)
    save!
  end

  protected

  def reindex_words
    words.reload
    words.each(&:reindex)
  end

  def remove_old_word_references(params)
    new_lst = params[:words].map { |w| w[:value] }
    words.each do |word|
      entries.where(word: word).destroy_all unless word.value.in?(new_lst)
    end
  end

  def word_reference(params, current_user)
    data = { value: params[:to_param], language_id: params[:language_id],
             user_id: current_user.id }
    word = Word.find_or_initialize_by(data)
    entry_reference(word)
    word
  end

  def entry_reference(word)
    return if entries.find { |e| e.word_id == word.id }.present?
    entries.build(word: word)
  end
end
