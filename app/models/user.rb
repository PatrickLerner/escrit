class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :native_language, class_name: Language
  has_many :buddies, foreign_key: "origin_id", class_name: "Buddy"
  has_many :services
  has_many :texts
  
  validates :name, presence: true

  after_initialize :init

  attr_writer :real

  def init
    self.audio_rate ||= 100
  end

  def real?
    @real
  end

  def valid_password?(password)
    return true if Rails.env.development?
    super
  end

  def languages
    Text.group(:language_id).select('language_id, sum(id) as sum').where(user_id: self.id, public: false).includes(:language).map { |text|
      text.language
    }.sort { |a, b| a.name <=> b.name }
  end

  def compliments
    Compliment.where(language: self.languages)
  end
end
