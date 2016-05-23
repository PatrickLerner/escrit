require 'rails_helper'

describe Entry, type: :model do
  it 'has a valid factory' do
    expect(build(:entry)).to be_valid
  end

  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_presence_of(:word) }
  it do
    create(:entry)
    is_expected.to validate_uniqueness_of(:token_id).scoped_to(:word_id)
  end

  it 'has a minimum rating of 0' do
    entry = build(:entry, rating: -1)
    expect(entry).to_not be_valid
  end

  it 'has a maximum rating of 5' do
    entry = build(:entry, rating: 6)
    expect(entry).to_not be_valid
  end

  it 'accepts ratings between 0 and 5' do
    word = create(:word)
    6.times do |i|
      entry = build(:entry, rating: i, word: word)
      expect(entry).to be_valid
    end
  end
end
