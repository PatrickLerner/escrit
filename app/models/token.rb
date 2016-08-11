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

  def non_empty_words(params)
    raise Token::DataParseError unless params.key?(:words)
    params[:words].reject do |data|
      data[:value].blank?
    end
  end

  def parse_and_save!(params, current_user)
    non_empty_words(params).each do |data|
      word_reference(data, current_user).parse_update(data, current_user)
    end
    remove_old_word_references(params)
    save!
  end

  def parse_update(params, current_user)
    parse_and_save!(params, current_user)
  rescue Token::DataParseError
    return false
  end

  protected

  def reindex_words
    words.reload
    words.each(&:reindex)
  end

  def remove_old_word_references(params)
    new_lst = params[:words].map { |w| w[:value] }
    words.where.not(value: new_lst).each do |word|
      entries.where(word: word).destroy_all
      word.destroy
    end
  end

  def word_reference(params, current_user)
    data = { value: params[:to_param], language_id: params[:language_id],
             user_id: current_user.id }
    word = Word.find_or_initialize_by(data)
    build_entry_reference(word)
    word
  end

  def build_entry_reference(word)
    ex_word = entries.find { |e| e.word_id == word.id && word.id.present? }
    return if ex_word.present?
    entries.build(word: word)
  end
end
