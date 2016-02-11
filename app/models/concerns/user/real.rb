# mixin for current_user to determine if it is the real current_user or rather
# a shadowed user object used by an admin
module User::Real
  extend ActiveSupport::Concern

  attr_writer :real

  def real?
    @real
  end
end
