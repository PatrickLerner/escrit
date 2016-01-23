require 'rails_helper'

describe 'user settings' do
  login_user

  it 'settings do not contain admin only things', js: true do
    visit settings_path

    expect(page).to have_content 'Services'
    expect(page).to have_content 'User Profile'
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
end

describe 'admin settings' do
  login_admin

  it 'settings show admin settings' do
    visit settings_path

    expect(page).to have_content 'Services'
    expect(page).to have_content 'User Profile'
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
