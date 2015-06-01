class Service < ActiveRecord::Base
  belongs_to :language
  default_scope { order('short_name asc, name asc') }
end
