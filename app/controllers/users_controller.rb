class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:show, :add, :remove]
  before_action :find_buddy, only: [:show, :add, :remove]

  def show
    @words = Note.joins(:word)
      .joins('left join languages on languages.id = words.language_id')
      .where('user_id = ? and rating < 6', params[:id]).group('languages.name')
      .order('languages.name asc').count
    @words_familiar = Note.joins(:word)
      .joins('left join languages on languages.id = words.language_id')
      .where('user_id = ? and rating < 6 and rating >= 3', params[:id])
      .group('languages.name').order('languages.name asc').count
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 30).order(:name)
  end

  def add
    if @user && !@is_buddy
      buddy = Buddy.new
      buddy.origin = current_user
      buddy.destination = @user
      buddy.save
    end
    redirect_to "/u/#{params[:id]}"
  end

  def remove
    @buddy.destroy if @user && @is_buddy
    redirect_to "/u/#{params[:did]}"
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
