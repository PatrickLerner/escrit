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

  describe 'last_opened_at' do
    it 'is set when creating a text' do
      expect(build(:text).last_opened_at).to be_nil
      expect(create(:text).last_opened_at).to_not be_nil
    end
  end

  describe 'uuid' do
    describe 'generation' do
      let(:text) { build(:text) }

      it 'sets a uuid when the model is persisted' do
        expect(text.uuid).to be_nil
        text.save!
        expect(text.uuid).to be_present
      end

      it 'does not change when saving the model again' do
        text.save!
        uuid = text.uuid
        text.save!
        text.title = 'test change'
        text.save!
        expect(text.uuid).to eq(uuid)
      end
    end

    describe 'validation' do
      VALID_UUIDs   = %w(000000 123456 a4F42f 8gfYYF).freeze
      INVALID_UUIDs = (
        %w(0 1234567 %D@#@FG !+$$$#@) +
        ['', 'test a']
      ).freeze

      it 'allows correct values' do
        VALID_UUIDs.each do |candidate|
          is_expected.to allow_value(candidate).for(:uuid)
        end
      end

      it 'disallows invalid values' do
        INVALID_UUIDs.each do |candidate|
          is_expected.to_not allow_value(candidate).for(:uuid)
        end
      end
    end
  end
end
