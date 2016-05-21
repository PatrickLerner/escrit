class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :native_language, class_name: Language
  has_many :services
  has_many :texts

  validates :name, uniqueness: true, length: { minimum: 3 }
  validate :validate_role

  after_initialize :set_defaults

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

  def languages
    Text.group(:language_id).select('language_id, sum(id) as sum')
        .where(user_id: id, public: false).includes(:language)
        .map(&:language).sort
  end

  def words_by_languages(min_rating: 0)
    Note.joins(:word).group('languages.name').order('languages.name asc')
        .where('user_id = ? and rating < 6 and rating >= ?', id, min_rating)
        .joins('left join languages on languages.id = words.language_id')
        .count
  end

  def compliments
    Compliment.where(language: languages)
  end

  def ability
    @ability ||= Ability.new(self)
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
end
