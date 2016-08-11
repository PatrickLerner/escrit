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
      order: collection_order,
      include: index_includes
    )
  end

  def collection_order
    { updated_at: :desc }
  end

  def index_includes
    []
  end

  def filter_params
    Hash[(params[:filters] || {}).to_h.map{ |k, v| [k, parse_filter_param(v)] }]
  end

  def parse_filter_param(value)
    return true if value == 'true'
    return false if value == 'false'
    value
  end

  def query
    if !filter_params['query'].try(:strip).blank?
      filter_params['query']
    else
      '*'
    end
  end

  def where_params
    filter_params.select { |key, _| key.to_s != 'query' }
                 .select { |_, val| !(val.is_a?(Array) && val.empty?) }
                 .merge(load_collection)
  end

  def load_collection
    {}
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
