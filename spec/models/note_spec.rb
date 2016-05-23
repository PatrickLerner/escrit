require 'rails_helper'

describe Note, type: :model do
  it 'has a valid factory' do
    expect(build(:note)).to be_valid
  end

  it { is_expected.to validate_length_of(:value).is_at_least(1) }
  it { is_expected.to validate_presence_of(:word) }
  it { is_expected.to validate_uniqueness_of(:value).scoped_to(:word_id) }
end
