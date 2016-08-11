class WordsController < ReadScaffoldController
  resource Word

  protected

  def load_object
    Word.owned_by(current_user).find_by(value: params[:id])
  end
end
