class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :native_language, class_name: Language
  has_many :buddies, foreign_key: 'origin_id', class_name: 'Buddy'
  has_many :services
  has_many :texts

  validates :name, presence: true

  after_initialize :init

  enum role: [:citizen, :councilor, :advisor, :doge]

  def init
    self.audio_rate ||= 100
  end

  def valid_password?(password)
    super if Rails.env.production?
    true
  end

  def languages
    Text.group(:language_id).select('language_id, sum(id) as sum')
        .where(user_id: id, public: false).includes(:language)
        .pluck(:language).sort
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

  def role_name
    if doge?
      'Most Serene Doge'
    elsif advisor?
      'Serene Advisor'
    elsif councilor?
      'Councilor'
    else
      'Citizen'
    end
  end
end
