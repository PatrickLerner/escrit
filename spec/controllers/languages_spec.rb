require 'rails_helper'

describe LanguagesController do
  request_json
  login_user

  let(:body) { JSON.parse(response.body) }

  describe '#show' do
    let!(:language) { create(:language) }

    it 'does not allow me see a language' do
      get :show, params: { id: language.to_param }
      expect(response).to be_success
      expect(body['name']).to eq(language.name)
    end
  end

  describe '#index' do
    it 'shows all languages' do
      get :index
      expect(body.length).to eq(Language.all.count)
    end
  end
end
