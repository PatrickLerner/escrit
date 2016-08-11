class TokensController < ScaffoldController
  resource Token

  def update
    if object.parse_update(permitted_params, current_user)
      render :show, status: :ok
    else
      render json: object.errors, status: :unprocessable_entity
    end
  end

  protected

  def load_object
    Token.find_or_initialize_by(value: params[:id])
  end

  def permitted_params
    params.require(:token).permit(:value, words: permitted_words_params)
  end

  def permitted_words_params
    [:id, :to_param, :value, :language_id, notes: []]
  end
end
