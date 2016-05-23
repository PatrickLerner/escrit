class TextsController < ScaffoldController
  resource Text

  def create
    @object = resource.new(permitted_params)
    @object.user     = current_user
    super
  end

  protected

  def load_object
    resource.owned_by(current_user).with_word_counts
            .find_by!(resource.param_field => params[:id])
  end

  def load_collection
    {
      user_id: current_user.id
    }
  end

  def permitted_params
    params.require(:text).permit(:id, :title, :content, :category, :language_id)
  end
end
