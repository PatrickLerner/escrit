require 'rails_helper'

describe Token, type: :model do
  it 'has a valid factory' do
    expect(build(:token)).to be_valid
  end

  it { is_expected.to validate_length_of(:value).is_at_least(1) }

  it 'should always correctly parameterize as its value field' do
    token = build(:token)
    expect(token.to_param).to eq(token.value)
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
    token = create(:token, value: stupid_characters)
    expect(token.value).to eq(normal_characters)
  end

  it 'it destroys itself along with its last association' do
    create(:token, value: 'token1')
    token2 = create(:token, value: 'token2')
    text = create(:text, title: 'token1 token2', content: 'token1 token2')
    word = create(:word, language: text.language, user: text.user)
    token2.words << word
    expect(word.tokens.length).to eq(1)
    text.destroy
    expect(Token.find_by(value: 'token1')).to be_nil
    expect(Token.find_by(value: 'token2')).to_not be_nil
    word.destroy
    expect(Token.find_by(value: 'token2')).to be_nil
  end
end
