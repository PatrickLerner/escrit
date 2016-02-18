class StatisticsController < ApplicationController
  include LanguageIndexPage
  include TextsHelper
  include ApplicationHelper

  before_action :authenticate_user!

  DAYS_OF_THE_WEEK =
    %w(Monday Tuesday Wednesday Thursda Friday Saturday Sunday).freeze

  WEEK_LABELS = (2..14).to_a.reverse.map { |i| "#{i} weeks ago" } +
                ['last week', 'this week']

  def index
    @new_words_this_week = new_words_this_week
    @new_words = new_words
    @new_text = new_text
    @total_words = total_words

    @total_read_texts = Text.completed.not_published.for_user(current_user)
                            .for_language(current_language).count
    @total_read_words = Text.completed.not_published.for_user(current_user)
                            .for_language(current_language).sum(:word_count)

    @vocabulary_data_c = []
    @vocabulary_data = []
    @vocabulary_labels = []
    @total_vocabulary_words = Note.vocabulary.for_user(current_user)
                                  .for_language(current_language).count
    last_count = 0
    14.times.each do |i|
      end_date = i.days.since.end_of_day

      voc_for_review = Note.vocabulary.for_user(current_user)
                           .for_language(current_language)
                           .where('review_at <= ?', end_date).count

      @vocabulary_data_c += [voc_for_review]
      @vocabulary_data += [voc_for_review - last_count]

      last_count = voc_for_review

      @vocabulary_labels += ["in #{i} days"]
    end
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

  def new_words_this_week
    data = []
    7.times do |day|
      data << Note.where(created_at: day_range_days_ago(day))
              .for_user(current_user).for_language(current_language).count
    end

    StatisticEntry.new data, DAYS_OF_THE_WEEK
  end

  def new_words
    data = []
    14.downto(0) do |week|
      data << Note.where(created_at: week_range_weeks_ago(week))
              .for_user(current_user).for_language(current_language).count
    end

    StatisticEntry.new data, WEEK_LABELS
  end

  def new_text
    data = []
    14.downto(0) do |week|
      data << Text.where(created_at: week_range_weeks_ago(week))
              .for_language(current_language).for_user(current_user).count
    end

    StatisticEntry.new data, WEEK_LABELS
  end

  def total_words
    data = []
    5.times do |rating|
      data << Note.where(rating: rating + 1).for_user(current_user)
              .for_language(current_language).count
    end

    StatisticEntry.new data, (1..5).to_s
  end
end
