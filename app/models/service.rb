class Service < ActiveRecord::Base
  belongs_to :user
  belongs_to :language
  default_scope { order('short_name asc, name asc') }

  validates :name, presence: true, length: { minimum: 3 }
  validates :short_name, presence: true, length: { minimum: 1 }
  validates :url, presence: true, length: { minimum: 10 }

  attr_accessor :published

  def published?
    @published
  end

  def ==(other)
    other.instance_of?(self.class) &&
    self.name == other.name &&
    self.short_name == other.short_name &&
    self.url == other.url &&
    self.language == other.language
  end

  def <=>(other)
    l_a = self.language.try(:name) || 'All'
    l_b = other.language.try(:name) || 'All'
    if (l_a <=> l_b) != 0
      l_a <=> l_b
    else
      self.name <=> other.name
    end
  end
  
  alias_method :eql?, :==
end
