require 'rails_helper'

describe 'dictation' do
  login_user

  let!(:language) { create(:language) }
  let!(:word) { create(:word, language: language) }
  let!(:note) { create(:note, vocabulary: true, user: user, word: word) }

  it 'shows when no vocabulary is available', js: true do
    visit language_dictation_path('russian')
    expect(page).to have_content 'You do not have any vocabulary in this language.'
  end

  it 'displays vocabulary correctly if it is available', js: true do
    expect(note.word.language).to eq(language)
    visit language_dictation_path(language)

    expect(page).to have_content 'Check answer'
    fill_in 'word', with: note.word.value
    expect(page).to_not have_content word.value
    expect(page).to_not have_content note.value
    click_link 'Check answer'

    expect(page).to have_content word.value
    expect(page).to have_content note.value
    click_link 'New word'

    expect(page).to_not have_content word.value
    expect(page).to_not have_content note.value
  end
end
