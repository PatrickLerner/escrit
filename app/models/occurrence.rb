class Occurrence < ActiveRecord::Base
  belongs_to :word
  belongs_to :text

  validates :word, presence: true
  validates :text, presence: true
  validates_uniqueness_of :word_id, scope: :text_id
end
