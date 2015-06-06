class StatisticsController < ApplicationController
  include TextsHelper
  
  def index
    @new_words_data = []
    @new_words_labels = []
    @new_texts_data = []
    @new_texts_labels = []
    14.downto(0).each { |i|
      start_date = (i*7).day.ago.beginning_of_week.beginning_of_day
      end_date = (i*7).day.ago.end_of_week.end_of_day
      if selected_language == nil
        @new_words_data += [Word.where(created_at: start_date..end_date).length]
        @new_texts_data += [Text.where(created_at: start_date..end_date).length]
      else
        @new_words_data += [Word.where(created_at: start_date..end_date, language_id: selected_language.id).length]
        @new_texts_data += [Text.where(created_at: start_date..end_date, language_id: selected_language.id).length]
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
  end
end
