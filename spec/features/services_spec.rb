require 'rails_helper'

describe 'services for users' do
  login_user

  it 'allows to list current services' do
    service = create(:service, user: user)
    visit services_path
    expect(page).to have_content service.name
    expect(page).to have_content service.short_name
  end

  it 'allows adding a new service, edit it and delete it', js: true do
    visit services_path
    click_link 'Add new'

    expect(page).to have_content 'New service'
    fill_in 'service_name', with: 'Wikifakia'
    fill_in 'Short name', with: 'fake'
    fill_in 'Url mask', with: 'http://fakia.fake/'
    expect(page).to have_content 'Your URL Mask does not work without the {query} placeholder!'
    click_link 'Add new'

    expect(page).to have_content 'Wikifakia'
    expect(page).to have_content 'fake'
    click_link 'Wikifakia'

    fill_in 'Url mask', with: 'http://fakia.fake/?q={query}'
    fill_in 'Short name', with: 'wfk'
    expect(page).to_not have_content 'Your URL Mask does not work without the {query} placeholder!'
    click_link 'Save'

    expect(page).to have_content 'Wikifakia'
    expect(page).to_not have_content 'fake'
    expect(page).to have_content 'wfk'
    click_link 'wfk'

    click_link 'Delete'
    expect(page).to_not have_content 'Wikifakia'
    expect(page).to_not have_content 'wfk'
  end

  it 'does not allow to save blank services', js: true do
    visit new_service_path
    expect(page).to have_content 'New service'
    click_link 'Add new'
    expect(page).to have_content "Name can't be blank"

    visit edit_service_path(create(:service, user: user))
    fill_in 'service_name', with: ''
    click_link 'Save'
    expect(page).to have_content "Name can't be blank"
  end
end

describe 'services for admins', js: true do
  login_admin

  it 'allows to publish services' do
    service = create(:service, user: user)

    visit services_path
    expect(page).to have_content service.name
    find('.fa-users').click

    expect(page).to have_content 'The service has been published.'
    new_service = Service.find(service.id + 1)
    expect(new_service.name).to eq(service.name)
    expect(new_service.user_id).to eq(0)
    expect(service.user_id).to eq(user.id)
  end
end
