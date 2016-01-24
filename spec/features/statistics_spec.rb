require 'rails_helper'

describe 'statistics' do
  login_user

  let(:language) { create(:language) }

  it 'should have a statistics page' do
    visit statistics_path(language)
    expect(page).to have_content 'You have added 0 words this week so far.'

    create(:note, user: User.last, language: language)
    visit statistics_path(language)
    expect(page).to have_content 'You have added 1 word this week so far.'
  end
end
