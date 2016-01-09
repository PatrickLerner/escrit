require 'rails_helper'

RSpec.describe Note, type: :model do
  it 'has a valid factory' do
    note = FactoryGirl.build :note
    expect(note).to be_valid
  end

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:word) }
  it { is_expected.to validate_presence_of(:rating) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:word) }

  it do
    FactoryGirl.create :note
    is_expected.to validate_uniqueness_of(:word_id).scoped_to(:user_id)
  end
  
  it 'has a minimum rating of 0' do
    note = FactoryGirl.build :note, rating: -1
    expect(note).to_not be_valid
  end

  it 'has a maximum rating of 6' do
    note = FactoryGirl.build :note, rating: 7
    expect(note).to_not be_valid
  end

  it 'accepts ratings between 0 and 6' do
    word = FactoryGirl.create :word
    7.times do |i|
      note = FactoryGirl.build :note, rating: i, word: word
      expect(note).to be_valid
    end
  end
end
