class WordsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @languages = Language.order(:name).all
    
    if params[:language]
      @search_term = params['q']
      lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
      @language_name = lang.name

      if @search_term == nil || @search_term.split == ''
        @notes = Note.joins(:word).order('words.created_at DESC').paginate(:page => params[:page], :per_page => 250).where 'user_id = ? and rating < 6 and language_id = ?', current_user.id, lang.id
      else
        @notes = Note.joins(:word).order('words.created_at DESC').paginate(:page => params[:page], :per_page => 250).where 'user_id = ? and rating < 6 and language_id = ? and (value ilike ? or note ilike ?)', current_user.id, lang.id, "%#{@search_term}%", "%#{@search_term}%"
      end

      @notes.map { |n|
        w = n.word
        w.value.gsub! '..', ' ... '
        w.value.gsub! '...', ' ... '
        w.value.gsub! '_', ' '
      }
    end
  end

  def show
    lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
    @word = Note.find_create lang.id, utf8downcase(params[:id]), current_user.id
    render json: {
      value: @word.word.value,
      note: @word.value.strip,
      language: @word.word.language.name,
      rating: @word.rating
    }
  end

  def update
    lang = Language.where("lower(name) = ?", params[:word][:language].downcase)[0]
    @note = Note.find_create lang.id, utf8downcase(params[:id]), current_user.id
    @note.value = params[:word][:note].strip if params[:word][:note]
    @note.rating = params[:word][:rating] if params[:word][:rating]
    
    if @note.word.save and @note.save
      render plain: "ok"
    else
      render plain: "failure"
    end

    if @note.value == '' and @note.rating == 0
      nodes = Node.where word_id: @note.word_id
      if nodes.length <= 1
        @note.word.delete
      end
      @note.delete
    end
  end

  private
    def word_params
      params.require(:word).permit(:language, :note, :rating)
    end
end
