class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find_by id: params[:id]
    @words = Word.joins(:language).where('user_id == ? and rating < 6', params[:id]).group('languages.name').count
  end
end
