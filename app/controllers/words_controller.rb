class WordsController < ReadScaffoldController
  resource Word

  def show
    unless object.present?
      render json: { errror: 'word not found' }, status: :not_found
    end
  end

  protected

  def load_object
    Word.owned_by(current_user).find_by(value: params[:id])
  end

  def load_collection
    {
      user_id: current_user.id
    }
  end
end
