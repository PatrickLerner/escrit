class ApplicationRecord < ActiveRecord::Base
  using StringRefinements
  self.abstract_class = true

  # overriden to allow models to specify something else but :id to be
  # used to identify them in a url call
  def to_param
    method(to_param_field).call.to_s.utf8downcase
  end

  protected

  # determines which field must be used when parameterizing this object
  # if the param field was changed, we still return the old one once
  def to_param_field
    if method("#{self.class.param_field}_changed?") && persisted?
      "#{self.class.param_field}_was"
    else
      self.class.param_field
    end
  end

  class << self
    # allow each model to specify a field which should be used to parameterize
    # the object in a url
    def param_field(param_field = nil)
      @param_field = param_field if param_field.present?
      @param_field ||= :id
    end
  end
end
