require 'rails_helper'

describe 'user settings' do
  login_user

  it 'settings do not contain admin only things', js: true do
    visit settings_path

    expect(page).to have_content 'Services'
    expect(page).to have_content 'User profile'
    expect(page).to_not have_content 'Languages'
    expect(page).to_not have_content 'Compliments'

    visit languages_path
    expect(page).to have_content 'You must be an administrator to do this!'
    visit replacements_path
    expect(page).to have_content 'You must be an administrator to do this!'
    visit artworks_path
    expect(page).to have_content 'You must be an administrator to do this!'
    visit compliments_path
    expect(page).to have_content 'You must be an administrator to do this!'
  end

  it 'allows changing the audio rate', js: true do
    visit settings_path

    click_link 'Audio settings'
    expect(page).to have_content 'Audio rate'
    range_select('user_audio_rate', 57)

    click_link 'Save'

    user.reload
    expect(user.audio_rate).to eq(57)
  end
end

describe 'admin settings' do
  login_admin

  it 'settings show admin settings' do
    visit settings_path

    expect(page).to have_content 'Services'
    expect(page).to have_content 'User profile'
    expect(page).to have_content 'Languages'
    expect(page).to have_content 'Compliments'

    visit languages_path
    expect(page).to have_content 'Admin settings'
    visit replacements_path
    expect(page).to have_content 'Admin settings'
    visit artworks_path
    expect(page).to have_content 'Language artworks'
    visit compliments_path
    expect(page).to have_content 'Admin settings'
  end
end
