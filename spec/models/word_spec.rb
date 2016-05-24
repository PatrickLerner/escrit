require 'rails_helper'

describe Word, type: :model do
  it 'has a valid factory' do
    expect(build(:word)).to be_valid
  end

  it { is_expected.to validate_length_of(:value).is_at_least(1) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to validate_presence_of(:user) }
  it do
    is_expected.to validate_uniqueness_of(:value).scoped_to(
      [:language_id, :user_id]
    )
  end

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
end
