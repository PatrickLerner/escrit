class Language < ActiveRecord::Base
  has_many :artworks
  has_many :compliments
  has_many :replacements
  has_many :texts
  has_many :words

  validates :name, presence: true, uniqueness: true

  default_scope { order(:name) }

  def to_param
    name.downcase
  end

  def current_artwork
    if artworks.count > 0
      start_date = Date.parse '2000-01-19 00:00:00 +0100'
      index = (DateTime.now - start_date).to_i % artworks.count
      artworks.limit(1).offset(index).first
    end
  end

  def current_artwork_style
    "background-image: url('#{current_artwork.image.url}');" if current_artwork
  end

  def has_vocabulary?(user)
    Note.joins(:word).where(
      'words.Language_id = ? AND user_id = ?', id, user.id
    ).where(vocabulary: true).count > 0
  end

  def <=>(other)
    name <=> other.name
  end
end
