class ReadScaffoldController < ApplicationController
  helper_method :object, :collection

  before_action :check_read_permission!, only: [:index, :show]

  def index
  end

  def show
  end

  protected

  def check_read_permission!
    authorize! :read, resource
  end

  def collection
    @collection ||= resource.all
  end

  def object
    @object ||= resource.find_by!(resource.param_field => params[:id])
  end

  def resource
    self.class.method(:resource).call
  end

  class << self
    private

    def resource(resource = nil)
      @resource ||= resource
    end
  end
end
