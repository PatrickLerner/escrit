class Replacement < ActiveRecord::Base
  belongs_to :language

  validates :value, presence: true

  default_scope { order(:language_id) }
end
