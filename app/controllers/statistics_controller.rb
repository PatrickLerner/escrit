class StatisticsController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper

  before_action :authenticate_user!

  DAYS_OF_THE_WEEK =
    %w(Monday Tuesday Wednesday Thursda Friday Saturday Sunday).freeze

  WEEK_LABELS = (2..14).to_a.reverse.map { |i| "#{i} weeks ago" } +
                ['last week', 'this week']

  IN_WEEK_LABELS = (0..13).to_a.map { |i| "in #{i} days" }

  def index
    @new_words_this_week = new_words_this_week
    @new_words = new_words
    @new_text = new_text
    @total_words = total_words
    @total_read_texts = total_read_texts
    @total_read_words = total_read_words
    @total_vocabulary_words = total_vocabulary_words
    @vocabulary_c = vocabulary_words(cumulative: true)
    @vocabulary   = vocabulary_words(cumulative: false)
  end

  private

  def day_range_days_ago(d)
    start_date = 0.day.ago.beginning_of_week.beginning_of_day + d.days
    end_date   = 0.day.ago.beginning_of_week.end_of_day       + d.days
    start_date..end_date
  end

  def week_range_weeks_ago(d)
    start_date = (d * 7).day.ago.beginning_of_week.beginning_of_day
    end_date   = (d * 7).day.ago.end_of_week.end_of_day
    start_date..end_date
  end

  def total_read_texts
    Text.completed.not_published.for_user(current_user)
        .for_language(current_language).count
  end

  def total_read_words
    Text.completed.not_published.for_user(current_user)
        .for_language(current_language).sum(:word_count)
  end

  def total_vocabulary_words
    Note.vocabulary.for_user(current_user).for_language(current_language).count
  end

  def new_words_this_week
    data = (0..6).to_a.map do |day|
      Note.where(created_at: day_range_days_ago(day))
          .for_user(current_user).for_language(current_language).count
    end
    StatisticEntry.new data: data, labels: DAYS_OF_THE_WEEK
  end

  def new_of(klass)
    data = (0..14).to_a.reverse.map do |week|
      klass.where(created_at: week_range_weeks_ago(week))
           .for_user(current_user).for_language(current_language).count
    end
    StatisticEntry.new data: data, labels: WEEK_LABELS
  end

  def new_words
    new_of(Note)
  end

  def new_text
    new_of(Text)
  end

  def total_words
    data = (1..5).to_a.map do |rating|
      Note.where(rating: rating).for_user(current_user)
          .for_language(current_language).count
    end
    StatisticEntry.new data: data, labels: (1..5).to_a
  end

  def vocabulary_words(cumulative: false)
    data = (0..13).to_a.map { |day| vocabulary_words_data_for_day(day) }
    data = data.each_with_index.map do |_, i|
      vocabulary_words_non_cumulative_process_day data, i
    end unless cumulative
    StatisticEntry.new data: data, labels: IN_WEEK_LABELS
  end

  def vocabulary_words_non_cumulative_process_day(data, day)
    if day.zero?
      data[day]
    else
      data[day] - data[day - 1]
    end
  end

  def vocabulary_words_data_for_day(day)
    Note.for_user(current_user).for_language(current_language)
        .vocabulary.review_by(day.days.since.end_of_day).count
  end
end
