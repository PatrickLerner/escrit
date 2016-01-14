class Text < ActiveRecord::Base
  include WordsHelper
  include ActionView::Helpers::TextHelper

  belongs_to :language
  belongs_to :user
  has_many :occurrences, dependent: :delete_all

  validates :category, presence: true
  validates :content, presence: true, length: { minimum: 4, maximum: 15000 }
  validates :language, presence: true
  validates :title, presence: true
  validates :user, presence: true

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

  def scan_words_content
    scan_words self.content
  end

  def scan_words text
    text.downcase.gsub(URI.regexp){
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

  def rated_words_count user
    Word.joins(:occurrences).joins('INNER JOIN "notes" ON "notes"."word_id" = "words"."id"').where('occurrences.text_id = ? AND notes.rating <> 0 AND notes.user_id = ?', self.id, user.id).count
  end

  def rated_words user
    Word.joins(:occurrences).joins('INNER JOIN "notes" ON "notes"."word_id" = "words"."id"').where('occurrences.text_id = ? AND notes.rating <> 0 AND notes.user_id = ?', self.id, user.id).map { |word| word.value }
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
    current_words = self.scan_words_content
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

    Occurrence.where(text: self).includes(:word).each do |o|
      if o.word.nil?
        o.delete
      end
    end
    
    if self.word_count != self.unique_word_count
      self.update(word_count: self.unique_word_count)
    end
  end

  def occurrences word
    x = self.content.split(/(?<=[^\.][\.\?!][^\.])|(?<=[\n])/).reduce([]) { |a, el|
      if (a != nil) && (a[-1] != nil) && (a[-1].scan(Text::WORD_REGEX).length == 1)
        a << ((a.pop + "\n" + el).strip)
      else
        a << (el.strip)
      end
    }
    x.select { |line|
      line = Word.determine_replacement_value ApplicationController.utf8downcase(line), self.language
      if line.downcase.include? word
        words = scan_words line
        words = words.map do |word|
          if word.include? '||'
            split = word.split '||'
            word = split[1..-1].join('||')
          end
          word
        end
        words.include? word
      else
        false
      end
    }.map { |line|
      line.gsub(Text::WORD_REGEX) { |token|
        token_val = Word.determine_replacement_value ApplicationController.utf8downcase(token), self.language
        if token_val.include? '||'
          split = token_val.split '||'
          token = split[0]
          token_val = ApplicationController.utf8downcase split[1..-1].join('||')
        end

        if word == token_val
          '<strong>' + token + '</strong>'
        else
          token
        end
      }.html_safe
    }
  end
end
