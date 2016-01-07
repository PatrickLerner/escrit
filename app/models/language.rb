class Language < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :words
  has_many :texts
  has_many :compliments
  has_many :replacements
  has_many :artworks

  def to_param
    self.name.downcase
  end

  def current_artwork
    self.artworks.sample
  end

  def current_artwork_style
    if self.current_artwork
      "background-image: url('#{self.current_artwork.image.url}');"
    end
  end
end
