require 'rails_helper'

describe TextsController do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  render_views
  login_user

  let(:user) { FactoryGirl.create(:user) }
  let(:body) { JSON.parse(response.body) }

  describe '#get' do
    let!(:my_text) { create(:text, user: user) }
    let!(:other_text) { create(:text) }

    it 'should allow me to see my onw text' do
      get :show, params: { id: my_text.uuid }
      expect(response).to be_success
      expect(body['title']).to eq(my_text.title)
    end

    it 'should not allow me to see the texts of others' do
      get :show, params: { id: other_text.uuid }
      expect(response).to_not be_success
      expect(body['title']).to_not eq(other_text.title)
    end

    describe 'last_opened_at' do
      before(:each) do
        my_text.update_attributes(last_opened_at: 10.minutes.ago)
        my_text.reload
      end

      let!(:second_text) { create(:text, user: user) }

      it 'should be set when looking at a text' do
        old_date = my_text.last_opened_at
        get :show, params: { id: my_text.uuid }
        my_text.reload
        expect(my_text.last_opened_at).to be > old_date
      end

      it 'should show the last opened text first in the listing' do
        get :show, params: { id: my_text.uuid }
        get :index
        expect(body['data'].length).to eq(2)
        expect(body['data'][0]['to_param']).to eq(my_text.to_param)
      end
    end

    describe 'admin' do
      it 'allows seeing all texts, including those of others' do
        user.update_attribute(:role, User::ROLE_ADMIN)
        get :show, params: { id: other_text.uuid }
        expect(response).to be_success
        expect(body['title']).to eq(other_text.title)
      end
    end

    describe 'moderator' do
      it 'allows seeing all texts, including those of others' do
        user.update_attribute(:role, User::ROLE_MODERATOR)
        get :show, params: { id: other_text.uuid }
        expect(response).to be_success
        expect(body['title']).to eq(other_text.title)
      end
    end
  end
end
