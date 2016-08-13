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

  DUP_ATTRIBUTES = %w(name short_name url language_id)

  def ==(other)
    other.instance_of?(self.class) &&
      as_json(only: DUP_ATTRIBUTES) == other.as_json(only: DUP_ATTRIBUTES)
  end

  def dup_for(user)
    user.services.create(as_json(only: DUP_ATTRIBUTES))
  end
end
