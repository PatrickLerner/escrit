require 'rails_helper'

describe 'help' do
  login_user

  it 'suggests me to seek help when I sign up' do
    visit root_path
    expect(page).to have_content 'Look for help.'
  end

  it 'has useful help links in the menu' do
    visit help_path
    expect(page).to have_content 'Help'
  end

  it 'can show help articles' do
    visit help_path
    expect(page).to have_content 'How do I use keyboard shortcuts?'
    click_link 'How do I use keyboard shortcuts?'
    expect(page).to have_content 'Rating words'
    expect(page).to have_content 'Back to Overview'
  end
end
