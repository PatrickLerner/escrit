require 'rails_helper'

describe 'compliments for users' do
  login_user

  it 'cannot be added or listed' do
    visit compliments_path
    expect(page).to have_content 'You must be an administrator to do this!'
    visit new_compliment_path
    expect(page).to have_content 'You must be an administrator to do this!'
  end

  it 'shows a compliment for a language if the user has one' do
    visit home_path
    expect(page).to have_content 'Nice to have you on board!'
    text = create(:text, user: user)
    compliment = create(:compliment, language: text.language)
    visit home_path
    expect(page).to have_content compliment.value
  end
end

describe 'compliments for admins' do
  login_admin

  it 'allows to list current compliments' do
    compliment = create(:compliment)
    visit compliments_path
    expect(page).to have_content compliment.value
  end

  it 'allows adding a new compliment, edit it and delete it', js: true do
    compliment = Faker::Lorem.sentence
    visit compliments_path
    click_link 'Add new'

    fill_in 'Compliment', with: compliment
    select 'Russian', from: 'Language'
    click_link 'Add'

    expect(page).to have_content compliment
    expect(page).to have_content 'Russian'
    click_link compliment

    compliment = Faker::Lorem.sentence
    fill_in 'Compliment', with: compliment
    select 'German', from: 'Language'
    click_link 'Save'

    expect(page).to have_content compliment
    expect(page).to have_content 'German'
    click_link compliment

    click_link 'Delete'
    expect(page).to_not have_content compliment
  end
end
