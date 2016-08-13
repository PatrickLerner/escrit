require 'rails_helper'

describe ServicesController do
  request_json
  login_user

  let(:body) { JSON.parse(response.body) }

  describe '#show' do
    let!(:my_service) { create(:service, user: user) }
    let!(:other_service) { create(:service, user: create(:user)) }

    it 'allows me to see my own service' do
      get :show, params: { id: my_service.id }
      expect(response).to be_success
      expect(body['name']).to eq(my_service.name)
    end

    it 'does not allow me to see other services' do
      get :show, params: { id: other_service.id }
      expect(response).to_not be_success
      expect(response.status).to eq(404)
      expect(body['error']).to_not be_blank
    end
  end

  describe '#create' do
    let(:service) { build(:service) }
    let(:payload) { service.as_json(only: %w(name short_name url language_id)) }

    it 'associates the user correctly' do
      post :create, params: { service: payload }
      expect(response).to be_success
      expect(Service.last.user).to eq(user)
    end
  end

  describe '#update' do
    let(:service) { create(:service, user: user) }
    let(:payload) { service.as_json(only: %w(name short_name url language_id)) }

    it 'is possible to update a service' do
      patch :update, params: {
        id: service.id, service: payload.merge('name' => 'New Name')
      }
      expect(response).to be_success
      expect(service.reload.name).to eq('New Name')
    end

    it 'returns an error if it is missing parameters' do
      patch :update, params: {
        id: service.id, service: payload.merge('name' => '')
      }
      expect(response).to_not be_success
      expect(response.status).to eq(422)
    end
  end
end
