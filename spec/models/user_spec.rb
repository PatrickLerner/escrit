require 'rails_helper'

describe User, type: :model do
  it 'has a valid factory' do
    user = build(:user)
    expect(user).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to have_many(:texts) }
  it { is_expected.to have_many(:services) }
  it { is_expected.to have_many(:buddies) }
end
