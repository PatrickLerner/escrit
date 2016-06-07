class ReadScaffoldController < ApplicationController
  helper_method :object, :collection

  before_action :check_read_permission_object!, only: :show
  before_action :check_read_permission_resource!, only: :index

  def index
  end

  def show
  end

  protected

  def check_read_permission_object!
    authorize! :read, object
  end

  def check_read_permission_resource!
    authorize! :read, resource
  end

  def collection
    @collection ||= resource.search(
      query,
      where: where_params, page: params[:page] || 1, per_page: 20,
      order: { updated_at: :desc }
    )
  end

  def query
    p = JSON.parse(params[:filters])
    if p.key?('query') && !p['query'].strip.blank?
      p['query']
    else
      '*'
    end
  end

  def where_params
    JSON.parse(params[:filters])
        .select { |key, val| !val.blank? && key.to_s != 'query' }
        .merge(load_collection)
  end

  def load_collection
    {}
  end

  def object
    @object ||= load_object
  end

  def load_object
    resource.find_by!(resource.param_field => params[:id])
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
