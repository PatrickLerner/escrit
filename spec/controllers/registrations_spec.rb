require 'rails_helper'

describe RegistrationsController do
  request_json

  let(:user_attributes) do
    {
      name: 'Peter Miller',
      email: 'petermiller@escrit.eu',
      password: 'test1234',
      password_confirmation: 'test1234',
    }
  end

  describe '#create' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'allows me to register as a new user' do
      post :create, params: { user: user_attributes }
      expect(response).to be_success
      expect(User.find_by(email: 'petermiller@escrit.eu')).to_not be_nil
    end
  end
end
