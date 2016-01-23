require 'rails_helper'

describe 'texts' do
  login_user

  it 'allows adding a text', js: true do
    visit language_choice_texts_path
    click_link 'Russian'
    click_link 'New text'
    title = Faker::Lorem.sentence
    category = Faker::Lorem.sentence
    fill_in 'Title', with: title
    fill_in 'Category', with: category
    fill_in 'Content', with: Faker::Lorem.paragraphs(10).join("\n")
    click_link 'Add text'

    expect(page).to have_content title
    expect(page).to have_content 'New text has been successfully added.'
    
    visit texts_path('russian')
    expect(page).to have_content category
    click_link category
    expect(page).to have_content title
  end
end
