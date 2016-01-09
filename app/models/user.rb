class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  validates :name, presence: true

  has_many :texts
  has_many :buddies, foreign_key: "origin_id", class_name: "Buddy"

  def valid_password?(password)
    if ::Rails.env == "development"
      true
    else
      super
    end
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
