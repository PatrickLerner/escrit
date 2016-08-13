require 'rails_helper'

describe SessionsController do
  request_json

  let(:password) { 'test1234' }
  let!(:user) do
    create(:user, password: password, password_confirmation: password)
  end

  let(:user_attributes) do
    {
      email: user.email,
      password: password
    }
  end

  let(:body) { JSON.parse(response.body) }

  describe '#create' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'allows me to sign in as a new user' do
      post :create, params: { user: user_attributes }
      expect(response).to be_success
      expect(body['name']).to eq(user.name)
    end
  end
end
