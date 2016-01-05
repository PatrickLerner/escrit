class Language < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :words
  has_many :texts
  has_many :compliments
  has_many :replacements
  has_many :language_artworks

  def to_param
    self.name.downcase
  end

  def current_language_artwork
    self.language_artworks.sample
  end

  def current_language_artwork_style
    if self.current_language_artwork
      "background-image: url(\"#{self.current_language_artwork.image.url}\");"
    end
  end
end
