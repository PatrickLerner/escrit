class Language < ActiveRecord::Base
  has_many :artworks
  has_many :compliments
  has_many :replacements
  has_many :texts
  has_many :words

  validates :name, presence: true, uniqueness: true

  def to_param
    self.name.downcase
  end

  def current_artwork
    if self.artworks.count > 0
      start_date = Date.parse "2000-01-19 00:00:00 +0100"
      index = (DateTime.now - start_date).to_i % self.artworks.count
      self.artworks.limit(1).offset(index).first
    end
  end

  def current_artwork_style
    if self.current_artwork
      "background-image: url('#{self.current_artwork.image.url}');"
    end
  end

  def has_vocabulary? user
    Note.joins(:word).where(
      'words.Language_id = ? AND user_id = ?',
      self.id, user.id
    ).where(vocabulary: true).count > 0
  end
end
