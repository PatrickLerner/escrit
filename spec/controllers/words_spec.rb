require 'rails_helper'

describe WordsController do
  before(:each) do
    sign_in(:user, create(:user))
  end

  it 'returns the word as a json object' do
    word = create(:word)

    get :show, xhr: true, params: { language_id: word.language, id: word.value, format: :json }
    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['value']).to eq(word.value)
    expect(json['note']).to eq('')
    expect(json['rating']).to eq(0)
    expect(json['language']).to eq(word.language.name)

    note = create(:note, word: word, user: User.last)
    get :show, xhr: true, params: { language_id: word.language, id: word.value, format: :json }
    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['value']).to eq(word.value)
    expect(json['note']).to eq(note.value)
    expect(json['rating']).to eq(note.rating)
    expect(json['language']).to eq(word.language.name)
  end
end
