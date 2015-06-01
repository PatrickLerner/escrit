class Text < ActiveRecord::Base
  include WordsHelper

  belongs_to :language
  default_scope { order('category asc, title asc') }
  validates :category, presence: true, length: { minimum: 4 }
  validates :title, presence: true, length: { minimum: 4 }
  validates :content, presence: true, length: { minimum: 4 }

  def difficulty
    raw = self.raw_words

    sum_rating = raw.map { |w|
      r = Word.find_create(w).rating
      (r * r) / 5.0
    }.inject { |sum,x| sum + x }

    return sum_rating.to_f / raw.count.to_f
  end

  def update_word_count
    write_attribute 'word_count', self.raw_words.count
  end

  def raw_words
    WordsHelper.raw_words read_attribute(:content)
  end

  def split_words
    WordsHelper.split_words read_attribute(:content)
  end

  def raw_words_title
    WordsHelper.raw_words read_attribute(:title)
  end

  def split_words_title
    WordsHelper.split_words read_attribute(:title)
  end
end
