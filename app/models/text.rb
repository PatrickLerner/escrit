class Text < ActiveRecord::Base
  using StringRefinements

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

  %w[content category title].each do |type|
    define_method "processed_#{type}" do |current_user|
      disabled_words = !current_user.real?
      disabled_words ||= current_user.native_language == self.language
      if current_user.native_language == self.language
        notes = {}
      else
        content = read_attribute(type).utf8downcase
        uniq_words = content.scan(Text::WORD_REGEX).sort.uniq
        notes = Note.find_create_bulk self.language, uniq_words, current_user
      end
      # tag words
      processed = read_attribute(type).gsub(Text::WORD_REGEX) { |word|
        if word.include? '||'
          split = word.split '||'
          word = split[0]
          word_value = split[1..-1].join('||').utf8downcase
        else
          word_value = word.utf8downcase
        end

        word_lower = word.utf8downcase
        word_value = Word.determine_replacement_value word_value, language
        rating = notes[word_value].rating if notes[word_value]

        # image with @ prefix
        if /@https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.jpg' or word_lower[-4..-1] == '.png')
          '<div class="u-centered"><a href="' + word.mb_chars[1..-1] + '" data-lightbox="images" class="image-link"><img class="border" src="' + word.mb_chars[1..-1] + '" /></a></div>'

        # image with no prefix
        elsif /https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.jpg' or word_lower[-4..-1] == '.png')
          '<div class="u-centered"><a href="' + word.mb_chars + '" data-lightbox="images" class="image-link"><img src="' + word.mb_chars + '" /></a></div>'

        # mp3 files
        elsif /https?:\/\/[\S]+/.match word_lower and (word_lower[-4..-1] == '.mp3')
          '<div><audio src="' + word.mb_chars + '" preload="none"></audio></div>'

        # youtube videos
        elsif /https?:\/\/www\.youtube\.com\/watch\?v=[A-Za-z0-9]+/.match word_lower
          youtube_id = word.mb_chars.split("=").last
          '<div class="embed-container"><iframe src="//www.youtube.com/embed/' + youtube_id + '"></iframe></div>'

        # normal words
        elsif not disabled_words
          "<span class='w word s#{rating}' title='#{word}' value='#{word_value}'>#{word}</span>"
        else
          "<span class='w s#{rating}' title='#{word}' value='#{word_value}'>#{word}</span>"
        end
      }
      # convert headers
      processed = processed.gsub(/^([#]+)[ \t]*(.*)[\n]*/, "\\1 \\2\n\n")
      processed = processed.gsub(/\r/, '')
      paragraphs = processed.split(/[\n]{2,}/)
      paragraphs = paragraphs.map { |p| p.strip }
      processed = if paragraphs.count > 1
        paragraphs.map { |p|
          if p[0] == '#'
            p = p.gsub(/^###[ \t]*(.*)[\n]*/, '<h5>\1</h5>')
            p = p.gsub(/^##[ \t]*(.*)[\n]*/, '<h4>\1</h4>')
            p = p.gsub(/^#[ \t]*(.*)[\n]*/, '<h3>\1</h3>')
          elsif p[0] == '>'
            p = p.gsub(/^>[ \t]*(.*)[\n]*/, '<blockquote>\1</blockquote>')
          elsif not (/<div/.match p)
            '<p>' + p + '</p>'
          else
            p
          end
        }.join
      else
        paragraphs.join
      end
      processed = processed.gsub(/\n/, "<br />")
      processed = processed.gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
      processed = processed.gsub(/__(.*?)__/, '<em>\1</em>')
      processed = processed.gsub(/\-\-\-[\-]*[\n]*/, '<hr />')
      processed = processed.gsub(/==[=]*[\n]*/, '<hr />')
      processed = processed.gsub(/\(\((.*?)\)\)/, '<span class="hint">(\1)</span>')
      processed.html_safe
    end
  end

  # returns if the given user is allowed to update the text
  # admins are allowed to update all texts, other users only their own
  # and only if their text has not been made public
  def is_allowed_to_update user
    user.admin? or (user.id == read_attribute(:user_id) and not read_attribute(:public))
  end

  def scan_words_content
    scan_words self.content
  end

  def scan_words text
    text.downcase.gsub(URI.regexp){
      ''
    }.scan(Text::WORD_REGEX).map { |w|
      Word.determine_replacement_value w.utf8downcase, self.language
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
      Occurrence.create word: word, text: self
    end

    # remove lost occurances and words (if no occurances remain for it)
    removed_words = Word.find_create_bulk self.language, lost_words
    removed_words.each do |value, word|
      occurrences = Occurrence.where word: word, text: self
      occurrences.destroy_all

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
      self.update_columns(word_count: self.unique_word_count)
    end
  end

  def occurrences word
    self.content.split(/(?<=[^\.][\.\?!][^\.])|(?<=[\n])/).select { |line|
      line = Word.determine_replacement_value line.utf8downcase, self.language
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
        token_val = Word.determine_replacement_value token.utf8downcase, self.language
        if token_val.include? '||'
          split = token_val.split '||'
          token = split[0]
          token_val = split[1..-1].join('||').utf8downcase
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
