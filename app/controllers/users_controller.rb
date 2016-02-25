class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :add, :remove]
  before_action :find_buddy, only: [:show, :add, :remove]

  def show
    @words = current_user.words_by_languages
    @words_familiar = current_user.words_by_languages(min_rating: 3)
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 30).order(:name)
  end

  def add
    if @user && !@is_buddy
      Buddy.create! origin: current_user, destination: @user
    end
    redirect_to "/u/#{params[:id]}"
  end

  def remove
    @buddy.destroy if @user && @is_buddy
    redirect_to "/u/#{current_user.id}"
  end

  private

  def find_buddy
    @buddy ||= Buddy.find_by(
      origin_id: current_user.id,
      destination_id: params[:id]
    )
    @is_buddy ||= !@buddy.nil?
  end

  def load_user
    @user = User.find_by id: params[:id]
  end
end
