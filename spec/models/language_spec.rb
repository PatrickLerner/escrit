require 'rails_helper'

describe Language, type: :model do
  it 'has a valid factory' do
    language = build(:language)
    expect(language).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to have_many(:artworks) }
  it { is_expected.to have_many(:compliments) }
  it { is_expected.to have_many(:replacements) }
  it { is_expected.to have_many(:texts) }
  it { is_expected.to have_many(:words) }

  it 'provides artworks if it has any' do
    language = create(:language)
    expect(language.current_artwork).to be_nil
    create(:artwork, language: language)
    expect(language.current_artwork).to_not be_nil
    expect(language.current_artwork_style).to_not be_nil
  end
end
