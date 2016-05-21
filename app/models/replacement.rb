class Replacement < ApplicationRecord
  belongs_to :language

  validates :value, presence: true
end
