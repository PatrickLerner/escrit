require 'rails_helper'

describe 'languages' do
  login_admin

  it 'allows to list current languages' do
    language = create(:language)
    visit languages_path
    expect(page).to have_content language.name
  end

  it 'allows adding a new language, edit it and delete it', js: true do
    language = Faker::Hipster.word
    visit languages_path
    click_link 'Add new'

    fill_in 'Language name', with: language
    fill_in 'Voice id', with: "#{language} Man"
    fill_in 'Voice rate', with: '0.7'
    click_link 'Add'

    expect(page).to have_content language
    click_link language

    new_language = 'newlanguage'
    fill_in 'Language name', with: new_language
    click_link 'Save'

    expect(page).to have_content new_language
    expect(page).to_not have_content language
    click_link new_language

    click_link 'Delete'
    expect(page).to_not have_content new_language
  end

  it 'does not allow to save blank named languages', js: true do
    visit new_language_path
    expect(page).to have_content 'New language'
    click_link 'Add new'
    expect(page).to have_content "Name can't be blank"

    visit edit_language_path(create(:language).id)
    fill_in 'Language name', with: ''
    click_link 'Save'
    expect(page).to have_content "Name can't be blank"
  end
end
