require 'rails_helper'

describe 'reader' do
  login_user

  it 'allows you to translate texts', js: true do
    visit reader_path('russian')
    expect(page).to have_content 'Quick reader'
    fill_in 'preview_text', with: 'This is a test!'
    click_link 'Read text'
    
    expect(page).to have_content 'This is a test!'
  end
end
