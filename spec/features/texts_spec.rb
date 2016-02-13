require 'rails_helper'

describe 'texts' do
  login_user

  let!(:language) { create(:language) }
  let!(:word) { create(:word, language: language) }
  let!(:note) { create(:note, user: user, word: word, rating: 3) }
  let!(:text) { create(:text, user: user, language: language, content: "This is a text which contains a #{word.value}.") }

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

  it 'auto completes category names', js: true do
    visit new_text_path(language)

    fill_in 'Category', with: text.category[0..1]
    page.execute_script %Q{ $('#text_category').trigger("focus") }
    page.execute_script %Q{ $('#text_category').trigger("keydown") }
    selector = "ul.ui-autocomplete li"
    expect(page).to have_selector selector
    page.execute_script "$(\"#{selector}\").mouseenter().click()"

    title = Faker::Lorem.sentence
    fill_in 'Title', with: title
    fill_in 'Content', with: Faker::Lorem.paragraphs(10).join("\n")
    click_link 'Add text'

    expect(page).to have_content title
    expect(page).to have_content text.category
  end

  it 'can show the vocabulary used in a text', js: true do
    visit text_path(text)
    visit vocabulary_text_path(text)
    expect(page).to have_content word.value
  end
end

describe 'category' do
  login_user

  let!(:language) { create(:language) }
  let!(:category) do
    text = create(:text, language: language, user: user)
    10.times {
      create(:text, category: text.category, language: language, user: user)
    }
    text.category
  end

  it 'allows changing the category for multiple texts', js: true do
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
