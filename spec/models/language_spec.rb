require 'rails_helper'

RSpec.describe Language, type: :model do
  it 'has a valid factory' do
    language = FactoryGirl.build :language
    expect(language).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to have_many(:artworks) }
  it { is_expected.to have_many(:compliments) }
  it { is_expected.to have_many(:replacements) }
  it { is_expected.to have_many(:texts) }
  it { is_expected.to have_many(:words) }
end
