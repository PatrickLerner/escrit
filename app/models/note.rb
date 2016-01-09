class Note < ActiveRecord::Base
  belongs_to :word
  belongs_to :user

  after_initialize :init

  def init
    self.rating ||= 0
  end

  def vocabulary?
    self.vocabulary == true
  end

  def update_review_at!
    next_review = DateTime.now

    next_review += 2.day   if self.rating == 0
    next_review += 3.days  if self.rating == 1
    next_review += 5.days  if self.rating == 2
    next_review += 7.days  if self.rating == 3
    next_review += 13.days if self.rating == 4
    next_review += 31.days if self.rating == 5
    next_review += 31.days if self.rating == 6
        
    self.update(review_at: next_review)
  end

  def self.find_create language, word, user
    word = Word.determine_replacement_value ApplicationController.utf8downcase(word), language
    w = Note.joins(:word).where('words.value = ? and words.language_id = ? and user_id = ?', word, language.id, user.id)
    if w.length == 0
      w = [Note.new(value: '', word: Word.find_create(language, word), user: user)]
    end
    return w[0]
  end

  def self.find_create_bulk language, words, user
    words = words.map { |w|
      if w.match(/(.*)\|\|(.*)/)
        wparts = w.match(/(.*)\|\|(.*)/)
        w = ApplicationController.utf8downcase wparts[2]
      end
      Word.determine_replacement_value w, language
    }.uniq
    remaining = words
    result = {}

    list = Note.includes(:word).joins(:word).where('words.value in (?) and words.language_id = ? and user_id = ?', words, language.id, user.id)
    list.each do |res|
      remaining.delete res.word.value
      word = ApplicationController.utf8downcase res.word.value
      result[word] = res
    end

    remaining_words = Word.find_create_bulk language, remaining
    remaining.each do |rem|
      word = ApplicationController.utf8downcase rem
      result[word] = Note.new value: '', word: remaining_words[word], user: user
    end

    return result
  end
end
