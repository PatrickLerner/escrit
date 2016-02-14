require 'rails_helper'

describe 'words' do
  login_user

  let!(:language) { create(:language) }
  let!(:word) { create(:word, language: language, value: 'squid') }

  it 'has a word list page' do
    note = create(:note, user: user, word: word, value: 'test')
    expect(note.word.language).to eq(language)
    visit edit_word_path(language, note.word.value.downcase)
    visit words_path(language)
    expect(page).to have_content note.word.value
    expect(page).to have_content note.value
  end

  it 'has a word detail page' do
    note = create(:note, user: user, word: word)
    expect(note.word.language).to eq(language)
    visit edit_word_path(language, note.word.value.downcase)
    expect(page).to have_content note.word.value
    expect(page).to have_content note.value
  end

  it 'should have a language index page' do
    visit language_choice_words_path
    expect(page).to have_content 'Choose language'
    expect(page).to have_content 'Word list'

    click_link 'German'
    expect(page).to have_content 'Word list'
    expect(page).to have_content 'German'
    expect(page).to_not have_content 'Russian'
  end

  it 'allows to search words', js: true do
    note = create(:note, user: user, word: word)
    expect(note.word.language).to eq(language)
    visit words_path(language) + "?q=#{note.value}"
    expect(page).to have_content note.word.value
    visit words_path(language) + "?q=#{note.value}XXX"
    expect(page).to have_content "No #{language.name} words match your search phrase \"#{note.value}XXX\"."
  end

  it 'should extract example sentences on the detailed word paged' do
    text = create(:text, content: 'This is an example sentence in English. This is a second one.', user: user)
    visit edit_word_path(text.language, 'example')
    expect(page).to have_content 'example'
    expect(page).to have_content 'sentence'
    expect(page).to_not have_content 'second'

    visit edit_word_path(text.language, 'second')
    expect(page).to_not have_content 'example'
    expect(page).to_not have_content 'sentence'
    expect(page).to have_content 'one'
  end
end
