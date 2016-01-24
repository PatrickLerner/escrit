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

describe 'category' do
  login_user

  let (:language) { create(:language) }
  let (:category) do
    text = create(:text, language: language, user: User.last)
    10.times {
      create(:text, category: text.category, language: language, user: User.last)
    }
    text.category
  end

  it 'allows changing the category for multiple texts', js: true do
    expect(Text.where(category: category, user: User.last).count).to eq(11)

    visit texts_path(language)
    expect(page).to have_content category
    click_link category
    find('.fa-pencil').click
    
    expect(page).to have_content "Edit #{language.name} category"
    fill_in 'Category', with: 'New category name'
    click_link 'Update texts'

    expect(page).to have_content 'New category name'
    expect(page).to_not have_content category
  end
end
