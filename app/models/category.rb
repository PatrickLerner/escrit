class Category < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :language
  has_many :texts

  def destroy
    super unless texts.any?
  end
end
