class TextsController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :load_text, only: [:show, :edit, :update, :copy, :destroy]
  before_action :load_services, only: [:show]

  def vocabulary
    @text = Text.find params[:id]

    if @text.nil? || !@text.is_allowed_to_view?(current_user)
      redirect_to language_choice_texts_path,
                  alert: 'You are not allowed to do that.'
    elsif current_user.native_language_id != @text.language_id
      @notes = Note.joins('INNER JOIN "occurrences" ON "notes"."word_id" = "occurrences"."word_id"').includes(:word).where('occurrences.text_id = ? AND notes.rating IN (1, 2, 3, 4, 5) AND notes.user_id = ?', @text.id, current_user.id).paginate(page: params[:page], per_page: 250)
    end
  end

  def copy
    if @text.nil? || !@text.is_allowed_to_view?(current_user)
      redirect_to language_choice_texts_path,
                  alert: 'You are not allowed to do that.'
    else
      @new_text = @text.dup
      @new_text.user = current_user
      @new_text.public = false
      @new_text.hidden = false
      @new_text.save

      redirect_to language_text_path(@new_text.language, @new_text),
                  notice: 'Text has been successfully copied into your library.'
    end
  end

  def create
    @text = Text.new(text_params)
    @text.user_id = current_user.id
    @text.public = false unless current_user.admin?

    if @text.save
      @text.save
      redirect_to @text, notice: 'New text has been successfully added.'
    else
      params[:language] = @text.language.name if @text.language
      render 'new'
    end
  end

  def edit
    @text = nil unless @text.is_allowed_to_update?(current_user)
  end

  def destroy
    @text.destroy unless @text.is_allowed_to_update?(current_user)

    url = '/texts/' + @text.language.name.downcase
    if @text.public
      url += '/public'
    elsif @text.hidden
      url += '/archive'
    end
    url += '#' + @text.category

    redirect_to url, notice: 'Text has been successfully deleted.'
  end

  def index(hidden = false, public = false)
    selected_category = params[:c]

    if current_language == nil
      my_texts = []
    else
      if public
        my_texts = Text.where(language: current_language, public: true, category: selected_category).order('category asc, title asc')
      else
        my_texts = Text.where(language: current_language, hidden: hidden, user: current_user, public: false, category: selected_category).order('category asc, title asc')
      end
    end
    @hidden = hidden
    @public = public

    if my_texts.any?
      @texts = {}
      my_texts.each do |t|
        @texts[t.category] = [] if not @texts.has_key? t.category
        @texts[t.category] += [t]
      end

      @texts.each { |category, texts|
        texts.sort! do |a, b|
          if a.title == b.title
            0
          elsif [a.title, b.title].natural_sort[0] == a.title
            -1
          else
            1
          end
        end
        @texts[category] = texts
      }
      @texts = @texts.sort.to_h
    else
      @texts = {}
    end

    if public
      @categories = Text.where(public: true, language: current_language).select('category, count(texts.id) as count').group(:category).map { |t| [t.category, t.count] }.sort.to_h
    else
      @categories = Text.where(user: current_user, hidden: hidden, public: false, language: current_language).select('category, count(texts.id) as count').group(:category).map { |t| [t.category, t.count] }.sort.to_h
    end

    if selected_category
      render 'index_texts'
    else
      render 'index'
    end
  end

  def archive
    index true
  end

  def public
    index false, true
  end

  def new
    @text = Text.new
  end

  def show
    if @text.nil?
      return redirect_to language_choice_texts_path, alert: 'This text does not exist.'
    end

    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to language_choice_texts_path, alert: 'You are not allowed to do that.'
    else
      @processed_text = @text.processed_content current_user
      @processed_title = @text.processed_title current_user
      @processed_category = @text.processed_category current_user
    end
  end

  def update
    if params[:completed] && ((current_user.id != @text.id) || @text.public)
      render plain: 'not allowed'
    elsif !@text.public || current_user.admin?
      if text_params[:public] && !current_user.admin?
        text_params[:public] = false
      end

      if text_params[:bulk_update]
        Text.where(category: @text.category, language_id: @text.language_id, public: @text.public, hidden: @text.hidden).update_all(category: text_params['category'], public: text_params['public'], hidden: text_params['hidden'])
        return redirect_to language_texts_path(current_language),
                           notice: 'Category has been successfully updated.'
      end

      if @text.update_attributes(text_params)
        if text_params[:completed]
          render plain: 'ok'
        else
          redirect_to language_text_path(@text.language, @text),
                      notice: 'Text has been successfully updated'
        end
      else
        render 'edit'
      end
    else
      redirect_to @text, alert: 'Text could not be updated!'
    end
  end

  private

  def load_text
    @text = Text.find_by id: params[:id]
  end

  def text_params
    params.require(:text).permit(
      :category, :title, :content, :language_id, :completed, :hidden, :public,
      :audio_url, :bulk_update)
  end
end
