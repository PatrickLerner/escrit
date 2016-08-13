require 'rails_helper'

describe ComplimentsController do
  request_json
  login_user

  let(:body) { JSON.parse(response.body) }

  describe '#index' do
    describe 'no languages' do
      it 'returns no result' do
        get :index
        expect(body.length).to eq(0)
      end
    end

    describe 'with language' do
      let!(:compliment) { create(:compliment) }
      let!(:language) { compliment.language }
      let!(:text) { create(:text, user: user, language: language) }

      it 'returns a compliment of the language I have' do
        get :index
        expect(body.length).to eq(1)
        expect(body[0]).to eq(compliment.value)
      end
    end
  end
end
