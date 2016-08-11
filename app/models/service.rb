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

  def ==(other)
    other.instance_of?(self.class) &&
      name == other.name &&
      short_name == other.short_name &&
      url == other.url &&
      language == other.language
  end
end
