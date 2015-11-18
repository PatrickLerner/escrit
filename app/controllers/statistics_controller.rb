class StatisticsController < ApplicationController
  before_filter :authenticate_user!
  include TextsHelper

  def index_language
      @languages = Language.order(:name).all
  end
  
  def index
    @new_words_this_week_data = []
    @new_words_this_week_labels = []
    @total_new_words_this_week = 0

    7.times { |i|
      start_date = 0.day.ago.beginning_of_week.beginning_of_day + i.days
      end_date = 0.day.ago.beginning_of_week.end_of_day + i.days

      new_words = Note.joins(:word).where(created_at: start_date..end_date, user_id: current_user.id).where('words.language_id = ?', selected_language.id).count

      @new_words_this_week_data += [new_words]
      @total_new_words_this_week += new_words
    }
    @new_words_this_week_labels = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]

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

      new_words = Note.joins(:word).where(created_at: start_date..end_date, user_id: current_user.id).where('words.language_id = ?', selected_language.id).count
      new_texts = Text.where(created_at: start_date..end_date, language_id: selected_language.id, user_id: current_user.id).count

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
      word_count = Note.joins(:word).where(rating: rating, user_id: current_user.id).where('words.language_id = ?', selected_language.id).count
      @words_data += [word_count.to_s]
      @words_labels += [rating.to_s]
    }
    @total_read_texts = Text.where(user_id: current_user.id, completed: true, language_id: selected_language.id, public: false).count
    @total_read_words = Text.where(user_id: current_user.id, completed: true, language_id: selected_language.id, public: false).sum(:word_count)
  end
end
