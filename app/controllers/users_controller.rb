class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find_by id: params[:id]
    @words = Word.joins(:language).where('user_id = ? and rating < 6', params[:id]).group('languages.name').order('languages.name asc').count
    @words_familiar = Word.joins(:language).where('user_id = ? and rating < 6 and rating >= 3', params[:id]).group('languages.name').order('languages.name asc').count
  end
end
