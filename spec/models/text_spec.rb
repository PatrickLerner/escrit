require 'rails_helper'

describe Text, type: :model do
  it 'has a valid factory' do
    text = build(:text)
    expect(text).to be_valid
  end

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:language) }
end


describe Text, '#scan_words_content', type: :model do
  it 'should detect words correctly' do
    text = build_stubbed(:text, content: "This is a test text. this is also still all texts! «Hello» oh my...", title: 'test TeXT')
    expect(text.scan_words_content).to eq(%w[a all also hello is my oh still test text texts this])
  end
end

describe Text, '#save', type: :model do
  it 'creates words when saved' do
    text = create(:text)

    # check that each word contained in the text, title exists as a word
    text.scan_words_content.each do |value|
      word = Word.find_by value: value, language: text.language
      expect(word).to_not be_nil
    end
  end

  it 'creates occurrences when saved' do
    text = create(:text)
    occurrences = Occurrence.where text: text

    expect(occurrences.length).to eq(text.scan_words_content.length)
  end

  it 'updates occurrences when saved' do
    text = create(:text)
    occurrences = Occurrence.where text: text

    expect(occurrences.length).to eq(text.scan_words_content.length)

    # old occurrences are deleted
    text.content = "this is a shorter text now"
    text.save
    occurrences = Occurrence.where text: text

    expect(occurrences.length).to eq(text.scan_words_content.length)

    # old words are deleted
    Word.all.each do |word|
      expect(word.occurrences.count).to be > 0
    end
  end
end
