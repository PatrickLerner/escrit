require 'rails_helper'

describe 'words' do
  login_user

  let!(:language) { create(:language) }
  let!(:note) { create(:note, user: User.last, word: create(:word, language: language)) }
  let!(:text) { create(:text, user: User.last, content: "This is a test text which contains a word. This word is #{note.word.value} and it is great. It even contains it twice, see: #{note.word.value}!", language: language) }

  it 'has a word list page' do
    visit words_path(note.word.language)
    expect(page).to have_content note.word.value
    expect(page).to have_content note.value
  end

  it 'has a word detail page' do
    visit edit_word_path(language, note.word.value.downcase)
    expect(page).to have_content note.word.value
    expect(page).to have_content note.value
  end
end
