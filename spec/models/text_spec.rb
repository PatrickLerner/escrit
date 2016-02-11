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

describe Text, '#process', type: :model do
  it 'should allow process native language text and have no highlights' do
    text = build_stubbed(:text, content: "test text no highlights")
    user = create(:current_user, native_language: text.language)

    content = text.processed_content(user)

    expect(content).to_not include('word')
    expect(content).to_not include('s0')
  end

  it 'should allow to embed youtube videos' do
    text = build_stubbed(:text, content: "https://www.youtube.com/watch?v=i5sG5ISgRuU\n\nYoutube embed")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('embed-container')
    expect(content).to include('i5sG5ISgRuU')
  end

  it 'should allow to embed audio files' do
    text = build_stubbed(:text, content: "http://example.com/1.mp3\n\nYoutube embed")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('audio')
    expect(content).to include('1.mp3')
  end

  it 'should allow to embed image files' do
    text = build_stubbed(:text, content: "http://example.com/1.jpg\n\nYoutube embed")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('lightbox')
    expect(content).to include('img')
    expect(content).to include('1.jpg')
  end

  it 'should allow to embed image files with border' do
    text = build_stubbed(:text, content: "@http://example.com/1.jpg\n\nYoutube embed")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('border')
    expect(content).to include('lightbox')
    expect(content).to include('img')
    expect(content).to include('1.jpg')
  end

  it 'should allow to have headlines' do
    text = build_stubbed(:text, content: "# example h1\n\ntest\n\n## example h2\n\n### h3\n\n\ntesti test")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('h3')
    expect(content).to include('h4')
    expect(content).to include('h5')
  end

  it 'should allow to have paragraphs' do
    text = build_stubbed(:text, content: "p1\n\np2\n\np3")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('p')
  end

  it 'should allow to have blockquotes' do
    text = build_stubbed(:text, content: "normal\n\n> test block\n\ntest")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('blockquote')
  end

  it 'should allow to have replaments' do
    text = create(:text, content: "Ich fange||fange..an heute an||fange..an.")
    user = create(:current_user)

    content = text.processed_content(user)

    expect(content).to include('fange..an')
    expect(content).to include('>fange<')
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
