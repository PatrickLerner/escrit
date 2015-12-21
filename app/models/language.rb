class Language < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :words
  has_many :texts
  has_many :compliments
  has_many :replacements

  def to_param
    self.name.downcase
  end
end
