require 'rails_helper'

describe TokensController do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  render_views
  login_user

  let(:user) { FactoryGirl.create(:user) }
  let(:body) { JSON.parse(response.body) }

  describe '#get' do
    let!(:token) { create(:token_with_words, user: user) }

    it 'should list the words it is a part of' do
      get :show, params: { id: token.value }
      expect(body['words'].count).to eq(3)
      expect(body['words'].map { |w| w['value'] }.sort).to eq(
        token.words_for_user(user).map(&:value).sort
      )
    end
  end

  describe '#update' do
    let!(:token) { create(:token_with_words, user: user) }
    let!(:data) do
      {
        value: token.value,
        words: token.words_for_user(user).map do |word|
          {
            value: word.value,
            to_param: word.value,
            language_id: word.language_id,
            notes: word.notes
          }
        end
      }
    end

    it 'should update an existing word correctly with new notes' do
      data[:words] = data[:words].map do |word|
        word[:notes] += ['a note']
        word
      end
      patch :update, params: { id: token.value, token: data }
      token.words.each do |word|
        expect(word.notes.count).to eq(1)
        expect(word.notes[0].value).to eq('a note')
      end
    end

    it 'should be possible to add a new word' do
      new_word = create(:word)
      data[:words] += [{
        value: new_word.value,
        to_param: new_word.value,
        language_id: new_word.language_id,
        notes: new_word.notes
      }]
      word_count = token.words.count
      patch :update, params: { id: token.value, token: data }
      expect(token.words.count).to eq(word_count + 1)
      new_word.token_ids.include?(token.id)
    end

    it 'should allow renaming a word' do
      orig_word_name = data[:words][0][:value]
      orig_word_id = token.words[0].id
      data[:words][0][:value] = 'newword'
      patch :update, params: { id: token.value, token: data }
      expect(Word.find(orig_word_id).value).to eq('newword')
      expect(Word.where(value: orig_word_name).count).to eq(0)
    end
  end
end
