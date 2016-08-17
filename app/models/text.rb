class Text < ApplicationRecord
  include Tokenizable
  include TokenRelated
  include RandomUuid
  include OnCommitIndexed
  include Categorized

  param_field :uuid

  searchkick batch_size: 100

  has_and_belongs_to_many :tokens
  belongs_to :language
  belongs_to :user

  validates :content, length: { minimum: 1, maximum: 15_000 }
  validates :title, length: { minimum: 1 }
  validates :language, presence: true
  validates :user, presence: true

  normalize_attribute :category
  normalize_attribute :title
  normalize_attribute :content

  tokenized_fields :title, :content

  before_create :mark_as_opened!

  scope :search_import, -> { includes(:language, :tokens, :__category) }
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
    as_json(only: search_data_attributes).merge(
      language: language.name,
      tokens: tokens.loaded? ? tokens.map(&:value) : tokens.pluck(:value),
      public: public || false
    )
  end

  def search_data_attributes
    %w(title language_id user_id public created_at updated_at last_opened_at) +
      %w(uuid category category_id)
  end

  def word_count
    read_attribute(:word_count) || tokens.count
  end

  def mark_as_opened!
    no_save_after = changed? || !persisted?
    self.last_opened_at = DateTime.now
    save! unless no_save_after
  end

  def published?
    self.public
  end
end
