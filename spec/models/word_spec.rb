require 'rails_helper'

describe Word, type: :model do
  it 'has a valid factory' do
    expect(build(:word)).to be_valid
  end

  it { is_expected.to validate_length_of(:value).is_at_least(1) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to validate_presence_of(:user) }

  it 'should always correctly parameterize as its value field' do
    word = build(:word)
    expect(word.to_param).to eq(word.value)
  end

  it { is_expected.to allow_value('word').for(:value) }
  it { is_expected.to allow_value('слов').for(:value) }
  it { is_expected.to allow_value('кристина').for(:value) }
  it { is_expected.to allow_value('something-different').for(:value) }
  it { is_expected.to_not allow_value('WorD').for(:value) }
  it { is_expected.to_not allow_value('слов  ').for(:value) }
  it { is_expected.to_not allow_value('Кристина').for(:value) }
  it { is_expected.to_not allow_value('something different').for(:value) }

  it 'is expected to clean up umlaut messes' do
    stupid_characters = 'dümm'
    normal_characters = 'dümm'
    word = create(:word, value: stupid_characters)
    expect(word.value).to eq(normal_characters)
  end

  describe 'searchkick' do
    let!(:word) { 10.times { create(:word_with_tokens) } }

    it 'should not make unnecessairy queries when indexing' do
      expect { Word.reindex }.to make_database_queries(count: 5)
    end
  end

  describe 'word combination' do
    let(:language) { create(:language) }
    let(:user) { create(:user) }
    let(:word_one) { create(:word_with_tokens, language: language, user: user) }
    let(:word_two) { create(:word_with_tokens, language: language, user: user) }

    it 'does not combine if they are dissimilar' do
      orig_word_two_value = word_two.value
      word_two.value = word_one.value
      word_two.language = create(:language)
      word_two.save
      expect(Word.where(value: orig_word_two_value).count).to eq(0)
      expect(Word.where(value: word_one.value).count).to eq(2)
    end

    it 'combines words when they have the same name, language and user' do
      orig_word_two_value = word_two.value
      word_two.value = word_one.value
      word_two.save!
      expect(Word.where(value: orig_word_two_value).count).to eq(0)
      expect(Word.where(value: word_two.value).count).to eq(1)
    end

    it 'transfers all notes and tokens to the other word' do
      create(:note, word: word_one)
      create(:note, word: word_one)
      create(:note, word: word_two)
      create(:note, word: word_two)
      create(:note, word: word_two)
      expect(word_one.notes.count).to eq(2)
      expect(word_two.notes.count).to eq(3)
      token_count = word_one.tokens.count + word_two.tokens.count
      word_two.value = word_one.value
      word_two.save!
      expect(word_two.notes.count).to eq(5)
      expect(word_two.tokens.count).to eq(token_count)
    end

    it 'can correctly merge three ways' do
      uid = create(:user).id
      lid = create(:language).id
      buil_t = create(:token, value: 'был')
      buil_w = create(:word, value: 'был', user_id: uid, language_id: lid)
      create(:entry, word: buil_w, token: buil_t)
      create(:note, value: '(pm) was', word: buil_w)

      buila_t = create(:token, value: 'была')
      buila_w = create(:word, value: 'была', user_id: uid, language_id: lid)
      create(:entry, word: buila_w, token: buila_t)
      create(:note, value: 'was', word: buila_w)

      buit_t = create(:token, value: 'быть')
      buit_w = create(:word, value: 'быть', user_id: uid, language_id: lid)
      create(:entry, word: buit_w, token: buit_t)
      create(:note, value: 'to be', word: buit_w)

      buila_w.value = buil_w.value
      buila_w.save!
      buila_w.reload
      notes = buila_w.notes
      notes[0].update_attributes(value: 'to be')
      notes[1..-1].each(&:destroy)

      buila_w.value = 'быть'
      buila_w.save!

      expect(
        Word.where(value: %w(был была), language_id: lid, user_id: uid).count
      ).to eq(0)
      expect(
        Word.where(value: 'быть', language_id: lid, user_id: uid).count
      ).to eq(1)
      expect(
        Word.find_by(value: 'быть', language_id: lid, user_id: uid).notes.count
      ).to eq(1)
      expect(
        Word.find_by(value: 'быть', language_id: lid, user_id: uid).tokens.count
      ).to eq(3)
    end
  end
end
