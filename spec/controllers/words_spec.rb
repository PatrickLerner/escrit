require 'rails_helper'

describe WordsController do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  render_views
  login_user

  let(:user) { FactoryGirl.create(:user) }
  let(:body) { JSON.parse(response.body) }

  describe '#get' do
    let!(:word) { create(:word_with_notes, user: user, note_count: 3) }

    it 'should be possible to retrieve an existing word' do
      get :show, params: { id: word.value }
      expect(response).to be_success
      expect(body['value']).to eq(word.value)
      expect(body['notes'].count).to eq(word.notes.count)
    end

    it 'should return an error if the word does not exist' do
      get :show, params: { id: 'thisbeanewword' }
      expect(response).to_not be_success
    end
  end
end
