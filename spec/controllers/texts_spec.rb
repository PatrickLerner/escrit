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
      get :show, params: { id: my_text.id }
      expect(response).to be_success
      expect(body['title']).to eq(my_text.title)
    end

    it 'should not allow me to see the texts of others' do
      get :show, params: { id: other_text.id }
      expect(response).to_not be_success
      expect(body['title']).to_not eq(other_text.title)
    end

    describe 'admin' do
      it 'allows seeing all texts, including those of others' do
        user.update_attribute(:role, User::ROLE_ADMIN)
        get :show, params: { id: other_text.id }
        expect(response).to be_success
        expect(body['title']).to eq(other_text.title)
      end
    end

    describe 'moderator' do
      it 'allows seeing all texts, including those of others' do
        user.update_attribute(:role, User::ROLE_MODERATOR)
        get :show, params: { id: other_text.id }
        expect(response).to be_success
        expect(body['title']).to eq(other_text.title)
      end
    end
  end
end
