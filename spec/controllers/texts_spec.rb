require 'rails_helper'

describe TextsController do
  request_json
  login_user

  let(:body) { JSON.parse(response.body) }

  describe '#index' do
    let(:unique_word) { 'StrangWordiness' }
    let!(:first_text) { create(:text, user: user, title: unique_word) }
    let!(:second_text) { create(:text, user: user) }

    it 'shows all the texts of a user' do
      get :index
      expect(body['data'].length).to eq(user.texts.count)
    end

    it 'allows to filter a users texts' do
      get :index, params: { filters: { query: unique_word } }
      expect(body['data'].length).to eq(1)
      expect(body['data'][0]['title']).to eq(unique_word)
    end
  end

  describe '#delete' do
    let!(:my_text) { create(:text, user: user) }
    let!(:other_text) { create(:text) }

    it 'allows deleting your own texts' do
      delete :destroy, params: { id: my_text.to_param }
      expect(response).to be_success
      expect(Text.find_by(id: my_text.id)).to be_nil
    end

    it 'does not allow deleting other texts' do
      delete :destroy, params: { id: other_text.to_param }
      expect(response).to_not be_success
      expect(Text.find_by(id: other_text.id)).to eq(other_text)
    end
  end

  describe '#create' do
    let(:text) { build(:text) }
    let(:payload) { text.as_json(only: %w(title content category language_id)) }

    it 'is possible to create a new text' do
      post :create, params: { text: payload }
      expect(response).to be_success
      expect(Text.last.title).to eq(text.title)
    end

    it 'associates the user correctly' do
      post :create, params: { text: payload }
      expect(response).to be_success
      expect(Text.last.user).to eq(user)
    end

    it 'returns an error if it is missing parameters' do
      text.title = ''
      post :create, params: { text: payload }
      expect(response).to_not be_success
      expect(response.status).to eq(422)
    end
  end

  describe '#get' do
    let!(:my_text) { create(:text, user: user) }
    let!(:other_text) { create(:text) }

    it 'should allow me to see my onw text' do
      get :show, params: { id: my_text.to_param }
      expect(response).to be_success
      expect(body['title']).to eq(my_text.title)
    end

    it 'should not allow me to see the texts of others' do
      get :show, params: { id: other_text.to_param }
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
        get :show, params: { id: my_text.to_param }
        my_text.reload
        expect(my_text.last_opened_at).to be > old_date
      end

      it 'should show the last opened text first in the listing' do
        get :show, params: { id: my_text.to_param }
        get :index
        expect(body['data'].length).to eq(2)
        expect(body['data'][0]['to_param']).to eq(my_text.to_param)
      end

      describe 'public text' do
        before(:each) do
          my_text.update_attributes(public: true, created_at: 10.minutes.ago)
          second_text.update_attributes(public: true, created_at: 1.minute.ago)
          Text.reindex
        end

        it 'should not list texts which are public' do
          get :index
          expect(body['data'].length).to eq(0)
        end

        it 'should list texts in creation order for public texts' do
          get :index, params: { filters: { public: true } }
          expect(body['data'].length).to eq(2)
          expect(body['data'][0]['to_param']).to eq(second_text.to_param)
          expect(body['data'][1]['to_param']).to eq(my_text.to_param)
        end
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
