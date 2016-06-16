class TextsController < ScaffoldController
  resource Text

  after_action :mark_as_opened, only: [:show]

  def create
    @object = resource.new(permitted_params)
    @object.user = current_user
    super
  end

  protected

  def collection_order
    { last_opened_at: :desc }
  end

  def mark_as_opened
    object.mark_as_opened!
  end

  def load_object
    resource.with_word_counts.find_by!(resource.param_field => params[:id])
  end

  def load_collection
    return {} if filter_params['public']
    {
      user_id: current_user.id
    }
  end

  def permitted_params
    params.require(:text).permit(:id, :title, :content, :category, :language_id)
  end
end
