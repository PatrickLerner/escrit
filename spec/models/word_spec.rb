require 'rails_helper'

RSpec.describe Word, type: :model do
  it 'has a valid factory' do
    word = FactoryGirl.build :word
    expect(word).to be_valid
  end

  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to validate_uniqueness_of(:value).scoped_to(:language_id) }
end

RSpec.describe Word, '#find_create_bulk', type: :model do
  it 'can find or create instances' do
    values = %w[a all also hello is my oh still test text texts this]
    lang = FactoryGirl.create :language
    words = Word.find_create_bulk lang, values
    values.each do |value|
      expect(words[value].value).to eq(value)
      expect(words[value].language).to eq(lang)
    end
  end
end
