class StatisticsController < ApplicationController
  def index
    @new_words_data = []
    @new_words_labels = []
    14.downto(0).each { |i|
      @new_words_data += [Word.where(created_at: i.day.ago.beginning_of_day..i.day.ago.end_of_day).length]
      if i == 0
        @new_words_labels += ["today"]
      elsif i == 1
        @new_words_labels += ["yesterday"]
      else
        @new_words_labels += [i.to_s + " days ago"]
      end
    }
  end
end
