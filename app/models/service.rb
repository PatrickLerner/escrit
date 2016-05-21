class Service < ApplicationRecord
  belongs_to :user
  belongs_to :language
  default_scope { order('short_name asc, name asc') }

  validates :name, presence: true, length: { minimum: 3 }
  validates :short_name, presence: true, length: { minimum: 1 }
  validates :url, presence: true, length: { minimum: 10 }

  scope :enabled, -> { where(enabled: true) }
  scope :published, -> { where(user_id: 0) }
  scope :for_user, ->(user) { where(user: user) }

  def self.for_language(language)
    # language_id = 0 means for all languages
    where('language_id IN (?)', [0, language.id])
  end

  def published?
    user_id.zero?
  end

  def ==(other)
    other.instance_of?(self.class) &&
      name == other.name &&
      short_name == other.short_name &&
      url == other.url &&
      language == other.language
  end

  def <=>(other)
    l_a = language.try(:name) || 'All'
    l_b = other.language.try(:name) || 'All'
    if (l_a <=> l_b) != 0
      l_a <=> l_b
    else
      name <=> other.name
    end
  end
end
