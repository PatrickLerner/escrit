require 'rails_helper'

describe Occurrence, type: :model do
  let (:language) { create(:language) }
  let (:word)     { create(:word, language: language) }
  let (:text)     { create(:text, language: language) }

  subject { build(:occurrence, word: word, text: text) }

  it 'has a valid factory' do
    is_expected.to be_valid
  end

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:word) }
  it do
    create(:occurrence, word: word, text: text)
    is_expected.to validate_uniqueness_of(:word_id).scoped_to(:text_id)
  end
end
