require 'rails_helper'

describe 'vocabulary' do
  login_user

  let(:note) { create(:note, vocabulary: true, review_at: 5.days.ago, user: User.last) }

  it 'shows when no vocabulary is available', js: true do
    visit vocabulary_path('russian')
    expect(page).to have_content 'No more vocabulary left to train'
  end

  it 'displays vocabulary correctly if it is available', js: true do
    visit vocabulary_path(note.word.language)
    expect(page).to have_content 'Show answer'
    expect(page).to have_content note.word.value
    expect(page).to_not have_content note.value
    expect(page).to have_content '1 words left in the queue'
    click_link 'Show answer'
    expect(page).to have_content 'Correct answer'
    expect(page).to have_content note.value
    click_link 'Correct answer'
    expect(page).to have_content 'No more vocabulary left to train'
  end
end
