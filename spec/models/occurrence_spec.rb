require 'rails_helper'

RSpec.describe Occurrence, type: :model do
  let (:language) { FactoryGirl.create :language }
  let (:word)     { FactoryGirl.create :word, language: language }
  let (:text)     { FactoryGirl.create :text, language: language }

  subject { FactoryGirl.build :occurrence, word: word, text: text }

  it 'has a valid factory' do
    is_expected.to be_valid
  end

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:word) }
  it do
    FactoryGirl.create :occurrence, word: word, text: text
    is_expected.to validate_uniqueness_of(:word_id).scoped_to(:text_id)
  end
end
