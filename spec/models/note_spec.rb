require 'rails_helper'

describe Note, type: :model do
  it 'has a valid factory' do
    note = build(:note)
    expect(note).to be_valid
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:word) }
  it { is_expected.to validate_presence_of(:rating) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:word) }

  it do
    create(:note)
    is_expected.to validate_uniqueness_of(:word_id).scoped_to(:user_id)
  end
  
  it 'has a minimum rating of 0' do
    note = build(:note, rating: -1)
    expect(note).to_not be_valid
  end

  it 'has a maximum rating of 6' do
    note = build(:note, rating: 7)
    expect(note).to_not be_valid
  end

  it 'accepts ratings between 0 and 6' do
    word = create(:word)
    7.times do |i|
      note = build(:note, rating: i, word: word)
      expect(note).to be_valid
    end
  end
end
