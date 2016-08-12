require 'rails_helper'

describe ServicesController do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  render_views
  login_user

  let(:user) { FactoryGirl.create(:user) }
  let(:body) { JSON.parse(response.body) }

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
