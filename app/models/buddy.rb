class Buddy < ActiveRecord::Base
  belongs_to :origin, class_name: "User"
  belongs_to :destination, class_name: "User"

  default_scope { joins(:destination).order('users.name') }
end
