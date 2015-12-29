class Text < ActiveRecord::Base
  include WordsHelper
  include ActionView::Helpers::TextHelper

  belongs_to :language
  belongs_to :user
  default_scope { joins(:language) }
  validates :category, length: { minimum: 4 }
  validates :title, length: { minimum: 4 }
  validates :content, length: { minimum: 4, maximum: 10000 }
  validates :language_id, presence: true

  before_save :normalize_unicode
  after_save :update_occurrences

  WORD_REGEX = /@?\p{Alpha}[\p{Alpha}\-\|\.:\/\?=0-9%_]+[\p{Alpha}0-9]|\p{Alpha}+/i

  # returns if the given user is allowed to update the text
  # admins are allowed to update all texts, other users only their own
  # and only if their text has not been made public
  def is_allowed_to_update user
    user.admin? or (user.id == read_attribute(:user_id) and not read_attribute(:public))
  end

  def raw_words
    WordsHelper.raw_words read_attribute(:content)
  end

  def raw_words_title
    WordsHelper.raw_words read_attribute(:title)
  end

  def raw_words_category
    WordsHelper.raw_words read_attribute(:category)
  end

  def scan_words
    self.content.downcase.gsub(URI.regexp){
      ''
    }.scan(Text::WORD_REGEX).map { |w|
      Word.determine_replacement_value ApplicationController.utf8downcase(w), self.language
    }.sort.uniq
  end

  def unique_word_count
    Occurrence.where(text: self).count
  end

  def unique_words
    Word.joins(:occurrences).where('occurrences.text_id = ?', self.id).map { |word|
      word.value
    }
  end

  def rated_words user
    Word.joins(:occurrences).joins('INNER JOIN "notes" ON "notes"."word_id" = "words"."id"').where('occurrences.text_id = ? AND notes.rating <> 0 AND notes.rating <> 6 AND notes.user_id = ?', self.id, user.id).map { |word| word.value }.count
  end

  def content_cleaned
    self.content.gsub(URI.regexp, '').strip
  end

  def excerpt
    t = self.content_cleaned
    ["\n", ' '].each_with_index do |sep, i|
      t = truncate(t, length: 300 - i, separator: sep)
    end
    t
  end

  def content_processed
    process self.content
  end

  def normalize_unicode
    self.title = Unicode.normalize_KC(self.title).strip
    self.category = Unicode.normalize_KC(self.category).strip
    self.content = Unicode.normalize_KC(self.content).strip
  end

  def update_occurrences
    current_words = self.scan_words
    previous_words = self.unique_words

    gained_words = current_words - previous_words
    lost_words = previous_words - current_words

    # add gained words
    new_words = Word.find_create_bulk self.language, gained_words
    new_words.each do |value, word|
      word.save if word.new_record?
      occurrence = Occurrence.new word: word, text: self
      occurrence.save
    end

    # remove lost occurances and words (if no occurances remain for it)
    removed_words = Word.find_create_bulk self.language, lost_words
    removed_words.each do |value, word|
      occurrence = Occurrence.find_by word: word, text: self
      occurrence.destroy if occurrence

      # if the word is not referenced by occurances in texts or by definitions
      # of users, then it may now also be deleted permanently from the system
      if word.occurrences.count == 0 and word.notes.count == 0
        word.destroy
      end
    end
    
    if self.word_count != self.unique_word_count
      self.update(word_count: self.unique_word_count)
    end
  end
end
