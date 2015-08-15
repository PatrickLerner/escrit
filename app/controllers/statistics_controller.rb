class StatisticsController < ApplicationController
  before_filter :authenticate_user!
  include TextsHelper
  
  def index
    @new_words_data = []
    @new_words_labels = []
    @new_texts_data = []
    @new_texts_labels = []

    new_words_sum = 0
    @new_words_count = 0
    new_texts_sum = 0
    @new_texts_count = 0

    14.downto(0).each { |i|
      start_date = (i*7).day.ago.beginning_of_week.beginning_of_day
      end_date = (i*7).day.ago.end_of_week.end_of_day

      new_words = 0
      new_texts = 0

      if selected_language == nil
        new_words = Word.where(created_at: start_date..end_date, user_id: current_user.id).length
        new_texts = Text.where(created_at: start_date..end_date, user_id: current_user.id).length
      else
        new_words = Word.where(created_at: start_date..end_date, language_id: selected_language.id, user_id: current_user.id).length
        new_texts = Text.where(created_at: start_date..end_date, language_id: selected_language.id, user_id: current_user.id).length
      end

      @new_words_data += [new_words]
      @new_texts_data += [new_texts]

      if @new_words_count > 0 or new_words > 0
        @new_words_count += 1
        new_words_sum += new_words
      end

      if @new_texts_count > 0 or new_texts > 0
        @new_texts_count += 1
        new_texts_sum += new_texts
      end

      if i == 0
        @new_words_labels += ["this week"]
      elsif i == 1
        @new_words_labels += ["last week"]
      else
        @new_words_labels += [i.to_s + " weeks ago"]
      end
      @new_texts_labels = @new_words_labels
    }
    @new_words_average = 0
    @new_words_average = new_words_sum.to_f / @new_words_count.to_f if @new_words_count > 0
    @new_texts_average = 0
    @new_texts_average = new_texts_sum.to_f / @new_texts_count.to_f if @new_texts_count > 0

    @words_data = []
    @words_labels = []
    5.times { |i|
      rating = i + 1
      if selected_language == nil
        word_count = Word.where('rating = ? and user_id = ?', rating, current_user.id).count
      else
        word_count = Word.where('rating = ? and language_id = ? and user_id = ?', rating, selected_language.id, current_user.id).count
      end
      @words_data += [word_count.to_s]
      @words_labels += [rating.to_s]
    }
    if selected_language == nil
      @total_read_texts = Text.where(user_id: current_user.id, completed: true).count
      @total_read_words = Text.sum(:id, conditions: { user_id: current_user.id, completed: true})
    else
      @total_read_texts = Text.where(user_id: current_user.id, completed: true).count
      @total_read_words = Text.sum(:id, conditions: { user_id: current_user.id, completed: true, language_id: selected_language.id })
    end
  end
end
