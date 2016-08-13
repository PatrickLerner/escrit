class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :native_language, class_name: Language
  has_many :services
  has_many :texts

  validates :name, uniqueness: true, length: { minimum: 3 }
  validate :validate_role

  after_initialize :set_defaults
  after_create :add_services

  ROLES = [
    ROLE_ADMIN     = :admin,
    ROLE_MODERATOR = :moderator,
    ROLE_USER      = :user
  ].freeze

  ROLES.each do |role|
    define_method "#{role}?" do
      self.role.try(:to_sym) == role
    end
  end

  def valid_password?(password)
    super if Rails.env.production?
    true
  end

  def language_ids
    texts.group('language_id').select('language_id, sum(texts.id)')
         .map(&:language_id)
  end

  def languages
    Language.where(id: language_ids)
  end

  def compliments
    Compliment.where(language_id: language_ids)
  end

  protected

  def validate_role
    unless role.try(:to_sym).in?(User::ROLES)
      errors.add(:role, 'must be a valid role')
    end
  end

  def set_defaults
    self.audio_rate ||= 100
    self.role ||= ROLE_USER
  end

  def add_services
    Service.published.each do |service|
      service.dup_for(self)
    end
  end
end
