require 'rails_helper'

describe 'user registration' do
  let(:password) { Faker::Internet.password }
  let(:user) { create(:user, password: password, password_confirmation: password) }

  it 'lets me register' do
    visit new_user_registration_path
    name = Faker::Internet.user_name
    fill_in 'Name', with: name
    fill_in 'Email', with: Faker::Internet.free_email
    password = Faker::Internet.password
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Sign up'

    expect(page).to have_content 'Welcome! You have signed up successfully.'
    expect(page).to have_content "Hello, #{name}!"
    expect(page).to have_content 'Nice to have you on board!'
  end

  it 'allows me to login' do
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    check 'Remember me'
    click_button 'Sign in'
    expect(page).to have_content "Hello, #{user.name}!"
  end
end
