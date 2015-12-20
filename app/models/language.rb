class Language < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :words
  has_many :texts
  has_many :compliments

  def to_param
    self.name.downcase
  end
end
