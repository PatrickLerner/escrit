class ReadScaffoldController < ApplicationController
  helper_method :object, :collection

  before_action :check_read_permission_object!, only: :show
  before_action :check_read_permission_resource!, only: :index

  protected

  def check_read_permission_object!
    if object.nil?
      return render json: { error: 'not found' }, status: :not_found
    end
    authorize! :read, object
  end

  def check_read_permission_resource!
    authorize! :read, resource
  end

  def collection
    @collection ||= resource.search(
      query,
      where: where_params, page: params[:page] || 1, per_page: 20,
      order: try_collection_order,
      include: try_index_includes
    )
  end

  def try_collection_order
    has_method = methods.include?(:collection_order)
    has_method ? collection_order : { updated_at: :desc }
  end

  def try_index_includes
    methods.include?(:index_includes) ? index_includes : []
  end

  def filter_params
    params[:filters] || {}
  end

  def query
    return '*' if filter_params['query'].try(:strip).blank?
    filter_params['query']
  end

  def where_params
    filter_params.select { |key, _| key.to_s != 'query' }
                 .select { |_, val| !(val.is_a?(Array) && val.empty?) }
                 .merge(try_load_collection)
  end

  def try_load_collection
    methods.include?(:load_collection) ? load_collection : {}
  end

  def object
    @object ||= load_object
  end

  def load_object
    resource.find_by(resource.param_field => params[:id])
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
