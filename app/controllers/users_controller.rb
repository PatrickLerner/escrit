class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = User.find_by id: params[:id]
    @words = Word.joins(:language).where('user_id = ? and rating < 6', params[:id]).group('languages.name').order('languages.name asc').count
    @words_familiar = Word.joins(:language).where('user_id = ? and rating < 6 and rating >= 3', params[:id]).group('languages.name').order('languages.name asc').count
    buddy = Buddy.find_by origin_id: current_user.id, destination_id: params[:id]
    @is_buddy = if buddy then true else false end
  end

  def add
    user = User.find_by id: params[:id]
    buddy = Buddy.find_by origin_id: current_user.id, destination_id: params[:id]
    if user and not buddy
      buddy = Buddy.new
      buddy.origin = current_user
      buddy.destination = user
      buddy.save
    end
    redirect_to '/u/' + params[:id]
  end

  def remove
    user = User.find_by id: params[:id]
    buddy = Buddy.find_by origin_id: current_user.id, destination_id: params[:id]
    if user and buddy
      buddy.destroy
    end
    redirect_to '/u/' + params[:did]
  end
end
