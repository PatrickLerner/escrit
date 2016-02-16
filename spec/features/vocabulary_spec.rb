require 'rails_helper'

describe 'vocabulary' do
  login_user

  let!(:language) { create(:language) }
  let!(:word) { create(:word, language: language, value: 'someword') }
  let!(:note) { create(:note, vocabulary: true, review_at: 5.days.ago, user: user, word: word, rating: 3) }
  let!(:text) { create(:text, user: user, language: language) }

  it 'shows when no vocabulary is available', js: true do
    visit vocabulary_path('russian')
    expect(page).to have_content 'No more vocabulary left to train'
  end

  it 'displays vocabulary correctly if it is available', js: true do
    visit vocabulary_path(note.word.language)
    wait_for_ajax
    expect(page).to have_content "#{note.word.language.name} vocabulary trainer"
    expect(page).to have_content 'Show answer'
    expect(page).to have_content note.word.value
    expect(page).to_not have_content note.value
    expect(page).to have_content '1 words left in the queue'
    click_link 'Show answer'
    expect(page).to have_content 'Correct answer'
    expect(page).to_not have_content 'Show answer'
    expect(page).to have_content note.value
    click_link 'Correct answer'
    expect(page).to have_content 'No more vocabulary left to train'
  end

  it 'allows to reset all vocabulary in the settings' do
    expect(Note.vocabulary.for_user(user).for_language(note.word.language).count).to eq(1)
    visit settings_path
    click_link 'Vocabulary'
    expect(page).to have_content language.name
    click_link 'Reset'
    expect(Note.vocabulary.for_user(user).for_language(language).count).to eq(0)
    expect(page).to have_content 'You do not have any vocabulary in any language.'
  end

  it 'allows to shuffle vocabulary in the settings' do
    100.times do |i|
      word = create(:word, language: language, value: "word#{i}")
      create(:note, vocabulary: true, review_at: 5.days.ago, user: user, word: word, rating: 3)
    end
    expect(Note.vocabulary.for_user(user).for_language(note.word.language).awaiting_review.count).to eq(101)
    visit settings_path
    click_link 'Vocabulary'
    expect(page).to have_content language.name
    click_link 'Shuffle'
    expect(Note.vocabulary.for_user(user).for_language(language).awaiting_review.count).to eq(50)
  end
end
