require 'rails_helper'

describe 'artworks' do
  login_admin

  it 'should have an artwork index page' do
    visit artworks_path
    expect(page).to have_content 'Choose language'
    expect(page).to have_content 'Language artworks'

    click_link 'German'
    expect(page).to have_content 'language artworks'

    artwork = create(:artwork)
    visit language_artworks_path(artwork.language)
    expect(page).to have_content artwork.language.name
  end

  it 'allows adding a new artwork, edit it and delete it', js: true do
    language = create(:language)
    visit language_artworks_path(language)
    click_link 'Add new'

    expect(page).to have_content 'New language artwork'
    click_link 'Add new'
    expect(page).to have_content "Image can't be blank"

    attach_file 'Artwork', Rails.root.join('app', 'assets', 'images', 'europe.jpg')
    click_link 'Add new'

    expect(page).to have_content 'New artwork has been successfully added.'
    expect(page).to have_content 'Large Header'

    click_link 'Save'
    expect(page).to have_content 'Artwork has been successfully updated.'

    attach_file 'Artwork', Rails.root.join('app', 'assets', 'images', 'factory.jpg')
    select 'German', from: 'Language'
    click_link 'Save'

    click_link 'Delete'
    expect(page).to have_content 'Artwork has been successfully deleted.'
  end
end
