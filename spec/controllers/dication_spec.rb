require 'rails_helper'

describe DictationController do
  let!(:user) { create(:user) }

  before(:each) do
    sign_in(:user, user)
  end

  it 'returns a vocabulary word as a json object' do
    note = create(:note, vocabulary: true, user: user)

    get :index, xhr: true, params: { language_id: note.word.language, format: :json }
    json = JSON.parse(response.body)

    expect(response).to be_success
    expect(json['value']).to eq(note.word.value)
    expect(json['note']).to eq(note.value)
    expect(json['rating']).to eq(note.rating)
    expect(json['language']).to eq(note.word.language.name)
    expect(json['vocabulary']).to eq(true)
  end
end
