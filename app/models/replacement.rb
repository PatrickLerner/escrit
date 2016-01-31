class Replacement < ActiveRecord::Base
  belongs_to :language

  validates :value, presence: true
end
