class Text < ApplicationRecord
  include Tokenizable
  include TokenRelated

  searchkick

  has_and_belongs_to_many :tokens
  belongs_to :language
  belongs_to :user

  validates :category, length: { minimum: 1 }
  validates :content, length: { minimum: 1, maximum: 15_000 }
  validates :title, length: { minimum: 1 }
  validates :language, presence: true
  validates :user, presence: true

  normalize_attribute :category
  normalize_attribute :title
  normalize_attribute :content

  tokenized_fields :title, :content

  scope :search_scope, -> { joins(:language).includes(:tokens) }
  scope :in_language, -> (language) { where(language_id: language.id) }
  scope :owned_by, -> (user) { where(user_id: user.id) }
  scope :with_word_counts, lambda {
    joins('LEFT JOIN texts_tokens ON texts_tokens.text_id = texts.id')
      .joins('LEFT JOIN tokens ON tokens.id = texts_tokens.token_id')
      .group('texts.id').select('count(tokens.id) as word_count, texts.*')
  }

  scope :published, -> { where(public: true) }
  scope :not_published, -> { where.not(public: true) }

  def search_data
    {
      title: title,
      language: language.name,
      tokens: tokens.pluck(:value)
    }
  end

  def word_count
    read_attribute(:word_count) || tokens.count
  end
end
