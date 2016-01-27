require 'rails_helper'

describe 'statistics' do
  login_user

  let(:language) { create(:language) }

  it 'should have a statistics page' do
    visit statistics_path(language)
    expect(page).to have_content 'You have added 0 words this week so far.'

    create(:note, user: user, word: create(:word, language: language))
    visit statistics_path(language)
    expect(page).to have_content 'You have added 1 word this week so far.'
    expect(page).to have_content 'In your best week you added 1 new word.'

    create(:text, user: user, language: language)
    visit statistics_path(language)
    expect(page).to have_content 'In your best week you added 1 new text.'
  end

  it 'should have a language index page' do
    visit language_choice_statistics_path
    expect(page).to have_content 'Choose language'
    expect(page).to have_content 'Statistics'

    click_link 'German'
    expect(page).to have_content 'Statistics'
    expect(page).to have_content 'German'
    expect(page).to_not have_content 'Russian'
  end
end
