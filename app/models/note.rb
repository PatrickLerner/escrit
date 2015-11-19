class Note < ActiveRecord::Base
  belongs_to :word
  belongs_to :user

  after_initialize :init

  def init
    self.rating ||= 0
  end

  def self.find_create language_id, word, user_id
    word = Word.determine_replacement_value ApplicationController.utf8downcase(word), language_id
    w = Note.joins(:word).where('words.value = ? and words.language_id = ? and user_id = ?', word, language_id, user_id)
    if w.length == 0
      w = [Note.new(value: '', word: Word.find_create(language_id, word), user_id: user_id)]
    end
    return w[0]
  end

  def self.find_create_bulk language_id, words, user_id
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = ApplicationController.utf8downcase wparts[2]
      end
      Word.determine_replacement_value w, language_id
    }.uniq
    remaining = words
    result = {}

    list = Note.includes(:word).joins(:word).where('words.value in (?) and words.language_id = ? and user_id = ?', words, language_id, user_id)
    list.each do |res|
      remaining.delete res.word.value
      word = ApplicationController.utf8downcase res.word.value
      result[word] = res
    end

    remaining_words = Word.find_create_bulk language_id, remaining
    remaining.each do |rem|
      word = ApplicationController.utf8downcase rem
      result[word] = Note.new value: '', word: remaining_words[word], user_id: user_id
    end

    return result
  end
end
