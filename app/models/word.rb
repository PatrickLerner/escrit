class Word < ApplicationRecord
  include NormalizedValued
  include TokenRelated

  searchkick batch_size: 200

  has_many :entries, inverse_of: :word, dependent: :destroy
  has_many :notes
  has_many :tokens, through: :entries
  belongs_to :language
  belongs_to :user

  validates :value, uniqueness: { scope: [:language_id, :user_id] }
  validates :language, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :notes, reject_if: :all_blank

  scope :search_import, lambda {
    includes(:language).includes(:tokens).includes(:notes)
  }

  after_save :merge_duplicate

  def search_data
    as_json(only: search_data_attributes).merge(
      tokens: all_tokens,
      notes: all_notes,
      language: language.try(:code)
    )
  end

  def search_data_attributes
    [:value, :user_id]
  end

  def parse_update(params, _current_user)
    parse_notes(params)
    parse_attributes(params)
    mark_duplicate
    save!
  end

  protected

  def mark_duplicate
    return unless duplicate.present?
    duplicate.update_attribute(:value, "#{duplicate.value}_marked_for_deletion")
  end

  def merge_duplicate
    return unless duplicate.present?
    migrate_attribute(:notes, from: duplicate, unique: :value)
    migrate_attribute(:entries, from: duplicate, unique: :token_id)
    duplicate.reload if duplicate.persisted?
    duplicate.destroy! if duplicate.persisted?
  end

  def migrate_attribute(what, from: self, to: self, unique: nil)
    from.method(what).call.each do |attr|
      attr.word_id = to.id
      check_uniqueness_and_save(what, attr, to: to, unique: unique)
    end
  end

  def check_uniqueness_and_save(what, attr, to: self, unique: nil)
    attr_val = attr.method(unique).call
    already_exists = to.method(what).call.map(&unique).include?(attr_val)
    return attr.destroy if already_exists
    attr.save!
  end

  def duplicate
    @duplicate ||= Word.where(
      value: value, language_id: language_id, user_id: user_id
    ).where.not(id: id).first.presence
  end

  def parse_attributes(params)
    %w(value language_id).each do |attribute|
      method("#{attribute}=").call(params[attribute]) if params.key?(attribute)
    end
  end

  def parse_notes(params)
    return unless params.key?(:notes)
    params[:notes].each do |value|
      notes.find_or_initialize_by(value: value).word = self
    end
    notes.where.not(value: params[:notes]).each(&:destroy)
  end

  def all_tokens
    tokens.loaded? ? tokens.map(&:value) : tokens.pluck(:value)
  end

  def all_notes
    notes.loaded? ? notes.map(&:value) : notes.pluck(:value)
  end
end
