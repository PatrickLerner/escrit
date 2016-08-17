module Categorized
  extend ActiveSupport::Concern

  def self.included(base)
    base.before_save :update_category
    base.after_save :destroy_marked_category
    base.belongs_to :__category, class_name: 'Category',
                                 foreign_key: :category_id, optional: true,
                                 dependent: :destroy
  end

  def category
    __category.try(:value)
  end

  def category=(value)
    new_category = find_or_initialize_persisted_category(value: value)
    @__category_destroy = __category if __category != new_category
    self.__category = new_category
  end

  protected

  def update_category
    self.__category.user_id = category_user_id
    self.__category.language_id ||= language_id
    reset_category unless __category.persisted?
  end

  def destroy_marked_category
    @__category_destroy.try(:destroy)
  end

  def reset_category
    if find_persisted_category.present?
      self.__category = find_persisted_category
    end
    @find_persisted_category = nil
  end

  def find_persisted_category
    @find_persisted_category ||= find_or_initialize_persisted_category
    @find_persisted_category = nil unless @find_persisted_category.persisted?
    @find_persisted_category
  end

  def find_or_initialize_persisted_category(options = {})
    Category.find_or_initialize_by({
      value: category,
      user_id: category_user_id,
      language_id: __category.try(:language_id) || language_id
    }.merge(options))
  end

  def category_user_id
    return nil if published?
    __category.try(:user_id) || user_id
  end
end
