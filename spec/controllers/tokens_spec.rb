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
      expect(response).to be_success
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
      expect(response).to be_success
      expect(token.words.count).to eq(word_count + 1)
      new_word.token_ids.include?(token.id)
    end

    it 'should allow renaming a word' do
      orig_word_name = data[:words][0][:value]
      orig_word_id = token.words[0].id
      data[:words][0][:value] = 'newword'
      patch :update, params: { id: token.value, token: data }
      expect(response).to be_success
      expect(Word.find(orig_word_id).value).to eq('newword')
      expect(Word.where(value: orig_word_name).count).to eq(0)
    end

    describe 'merge with different word' do
      it 'merges simple existing words' do
        fi_word = token.words[0]
        ex_word = create(:word_with_tokens, user: user,
                                            language: fi_word.language)
        create(:note, word: ex_word, value: 'xxx')
        create(:note, word: ex_word)
        create(:note, word: fi_word)
        create(:note, word: fi_word, value: 'xxx')
        token_count = ex_word.tokens.count
        data[:words][0][:value] = ex_word.value
        patch :update, params: { id: token.value, token: data }
        expect(response).to be_success
        new_token_count = Word.find_by(value: ex_word.value).tokens.count
        expect(new_token_count).to be > token_count
      end

      it 'merges double updated words' do
        fi_word = token.words[0]
        ex_word = create(:word_with_tokens, user: user,
                                            language: fi_word.language)
        data[:words][0][:value] = ex_word.value
        data[:words][1][:value] = ex_word.value
        patch :update, params: { id: token.value, token: data }
        expect(response).to be_success
      end
    end
  end

  describe 'merge behavior' do
    it 'merges strange1 correctly' do
      language = create(:language)
      payload = JSON.parse('{"value":"спросил","to_param":"спросил",'\
        '"words":[{"value":"спросить","to_param":"спросил","language_id":' +
        language.id.to_s + ',"language":"Russian","notes":["to ask"]}]}')

      token = create(:token, value: 'спросил')
      word = create(:word, value: 'спросил', user_id: user.id,
                           language_id: language.id)
      create(:entry, word: word, token: token)
      create(:note, value: 'to ask', word: word)

      token_ex = create(:token, value: 'спросить')
      word_ex = create(:word, value: 'спросить', user_id: user.id,
                              language_id: language.id)
      create(:entry, word: word_ex, token: token_ex)
      create(:note, value: 'to ask', word: word_ex)

      patch :update, params: { id: token.value, token: payload }

      expect(response).to be_success

      expect(Word.find_by(value: 'спросить').notes.count).to eq(1)
    end

    it 'merges with an existing word correctly' do
      language = create(:language)
      payload = JSON.parse('{"value":"спросил","to_param":"спросил",'\
        '"words":[{"value":"спросить","to_param":"спросил","language_id":' +
        language.id.to_s + ',"language":"Russian","notes":["to ask"]}]}')

      token = create(:token, value: 'спросил')
      word = create(:word, value: 'спросил', user_id: user.id,
                           language_id: language.id)
      create(:entry, word: word, token: token)
      create(:note, value: 'to ask 2', word: word)

      patch :update, params: { id: token.value, token: payload }

      expect(response).to be_success

      expect(Word.find_by(value: 'спросить').notes.count).to eq(1)
    end
  end
end
