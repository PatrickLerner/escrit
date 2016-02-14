class ReplacementsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_admin!
  before_action :load_replacement, only: [:edit, :destroy, :update]

  def create
    @replacement = Replacement.new(replacement_params)

    return render 'new' unless @replacement.save

    redirect_to replacements_path,
                notice: 'New replacement has been successfully added.'
  end

  def edit
  end

  def destroy
    @replacement.destroy

    redirect_to replacements_path,
                notice: 'Replacement has been successfully deleted.'
  end

  def index
    @replacements = Replacement.order(:language_id)
  end

  def new
    @replacement = Replacement.new
  end

  def update
    return render 'edit' unless @replacement.update(replacement_params)

    redirect_to replacements_path,
                notice: 'Replacement has been successfully updated.'
  end

  private

  def load_replacement
    @replacement = Replacement.find_by id: params[:id]
  end

  def replacement_params
    params.require(:replacement).permit(:replacement, :value, :language_id)
  end
end
