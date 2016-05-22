require 'rails_helper'

describe Text, type: :model do
  it 'has a valid factory' do
    expect(build(:text)).to be_valid
  end

  it { is_expected.to validate_length_of(:title).is_at_least(1) }
  it { is_expected.to validate_length_of(:content).is_at_least(1) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:language) }

  describe 'normalization' do
    it 'is expected to remove trailing whitespace from fields' do
      title = ' This is a stupid title with stupid whitepace  '
      content = '  All aboard the stupid train to stupid village   '
      text = create(:text, title: title, content: content)
      expect(text.title).to eq(text.title.strip)
      expect(text.content).to eq(text.content.strip)
    end

    it 'is supposed to normalize retarded combined unicode characters' do
      stupid_characters = 'Ällös is dümm'
      normal_characters = 'Ällös is dümm'
      expect(stupid_characters).to_not eq(normal_characters)
      text = create(:text, title: stupid_characters)
      expect(text.title).to eq(normal_characters)
    end

    it 'handles non-latin characters just as well' do
      text = create(:text, title: 'Я лыблю её.', content: 'Лыблю Её Я!')
      %w(я лыблю её).each do |word|
        w = Token.find_by(value: word)
        expect(w).to be_persisted
        expect(text.tokens).to include(w)
      end
      expect(text.tokens.count).to eq(3)
    end
  end

  describe 'tokenization' do
    it 'is supposed to tokenize itself' do
      text = create(:text, title: 'This is a test text',
                           content: 'All of this is good!')
      %w(this is a test text all of good).each do |token|
        w = Token.find_by(value: token)
        expect(w).to be_persisted
        expect(text.tokens).to include(w)
      end
      expect(text.tokens.count).to eq(8)
    end

    it 'should add new tokens when the text gets edited' do
      text = create(:text, title: 'totally', content: 'easy')
      expect(Token.find_by(value: 'bluemoonfish')).to be_nil
      expect(text.tokens.count).to eq(2)
      text.update_attributes(title: 'totally bluemoonfish')
      expect(Token.find_by(value: 'bluemoonfish')).to be_persisted
      expect(text.tokens.count).to eq(3)
    end
  end

  describe 'destroy' do
    it 'destroys tokens along with it if it gets destroyed' do
      language = create(:language)
      user = create(:user)
      text = create(:text, title: 'bluemoonfish', content: 'redmoonfish',
                           language: language, user: user)
      create(:text, title: 'bluemoonfish', content: 'bluemoonfish',
                    language: language, user: user)
      expect(Token.where(value: %w(bluemoonfish redmoonfish)).count).to eq(2)
      text.destroy
      expect(Token.where(value: %w(bluemoonfish redmoonfish)).count).to eq(1)
    end
  end

  describe 'searchkick' do
    let!(:texts) { 10.times { create(:text) } }

    it 'should not make unnecessairy queries when indexing' do
      expect { Text.reindex }.to make_database_queries(count: 4)
    end
  end
end
