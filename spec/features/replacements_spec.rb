require 'rails_helper'

describe 'replacements for users' do
  login_user

  it 'cannot be added or listed' do
    visit replacements_path
    expect(page).to have_content 'You must be an administrator to do this!'
    visit new_replacement_path
    expect(page).to have_content 'You must be an administrator to do this!'
  end
end

describe 'replacements for admins' do
  login_admin

  it 'allows to list current replacements' do
    replacement = create(:replacement)
    visit replacements_path
    expect(page).to have_content replacement.value
    expect(page).to have_content replacement.replacement
  end

  it 'allows adding a new replacement, edit it and delete it', js: true do
    replacement_value = "#{Faker::Hipster.word}_val"
    replacement = Faker::Hipster.word
    visit replacements_path
    click_link 'Add new'

    expect(page).to have_content 'New replacement'
    fill_in 'replacement_value', with: replacement_value
    fill_in 'replacement_replacement', with: replacement
    select 'Russian', from: 'Language'
    click_link 'Add new'

    expect(page).to have_content replacement_value
    expect(page).to have_content replacement
    click_link replacement

    new_replacement = Faker::Hipster.word
    fill_in 'replacement_replacement', with: new_replacement
    click_link 'Save'

    expect(page).to have_content replacement_value
    expect(page).to have_content new_replacement
    expect(page).to_not have_content replacement
    click_link new_replacement

    click_link 'Delete'
    expect(page).to_not have_content replacement_value
    expect(page).to_not have_content new_replacement
  end

  it 'does not allow to save blank replacements', js: true do
    visit new_replacement_path
    expect(page).to have_content 'New replacement'
    click_link 'Add new'
    expect(page).to have_content "Value can't be blank"

    visit edit_replacement_path(create(:replacement).id)
    fill_in 'replacement_value', with: ''
    click_link 'Save'
    expect(page).to have_content "Value can't be blank"
  end
end
