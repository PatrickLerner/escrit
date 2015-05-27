class Text < ActiveRecord::Base
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

  def self.seperators
    " \\t\\.\\?!:,\\-–\#\\n\\r\\(\\)\\[\\]\\{\\}\"\\\\/1234567890%><„,“;"
  end

  def raw_words
    content = read_attribute(:content).mb_chars.downcase.to_s
    content.scan /[^#{Text.seperators}]+[^ \n\t]*[^#{Text.seperators}]+|[^#{Text.seperators}]+/
  end

  def split_words
    content = read_attribute(:content)
    content.scan /[#{Text.seperators}]+|[^#{Text.seperators}]+[^ \n\t]*[^#{Text.seperators}]+|[^#{Text.seperators}]+/
  end
end
