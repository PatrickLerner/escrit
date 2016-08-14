module PermissionsHelper
  def permissions_for(object)
    Hash[%i(read update create destroy).map { |key|
      [key, can?(key, object)]
    }]
  end
end
