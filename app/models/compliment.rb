class Compliment < ActiveRecord::Base
  belongs_to :language
  default_scope { joins(:language).order('languages.name asc, value asc') }
end
