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

  it 'should have a language index page' do
    visit language_choice_reader_path
    expect(page).to have_content 'Choose language'
    expect(page).to have_content 'Quick reader'

    click_link 'German'
    expect(page).to have_content 'Quick reader'
    expect(page).to have_content 'German'
    expect(page).to_not have_content 'Russian'
  end

  it 'should support a get parameter to set the text' do
    visit reader_path('russian') + '?q=This is a test text!'
    expect(page).to have_content 'This is a test text!'
  end
end
