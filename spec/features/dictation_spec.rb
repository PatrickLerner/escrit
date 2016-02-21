require 'rails_helper'

describe 'dictation' do
  login_user

  let!(:note) { create(:note, vocabulary: true, user: user) }

  it 'shows when no vocabulary is available', js: true do
    visit language_dictation_path('russian')
    expect(page).to have_content 'You do not have any vocabulary in this language.'
  end

  it 'displays vocabulary correctly if it is available', js: true do
    visit language_dictation_path(note.word.language)
    expect(page).to have_content 'Check answer'
    fill_in 'word', with: note.word.value
    expect(page).to_not have_content note.word.value
    expect(page).to_not have_content note.value
    click_link 'Check answer'
    expect(page).to have_content note.word.value
    expect(page).to have_content note.value
    click_link 'New word'
    expect(page).to_not have_content note.word.value
    expect(page).to_not have_content note.value
  end
end
