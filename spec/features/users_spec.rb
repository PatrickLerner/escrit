require 'rails_helper'

describe 'users' do
  login_user

  it 'shows me my user page' do
    visit "/u/#{User.last.id}"
    expect(page).to have_content "#{User.last.name}"
  end

  it 'shows me all registered users' do
    visit '/u'
    expect(page).to have_content "#{User.last.name}"
  end
end
