require 'rails_helper'

describe User, type: :model do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  it { is_expected.to validate_length_of(:name).is_at_least(3) }

  it 'requires a role to be set' do
    expect(build(:user, role: nil)).to_not be_valid
  end

  it 'only allows valid roles' do
    User::ROLES.each do |role|
      expect(build(:user, role: role)).to be_valid
    end
    %w(blue fish balls bimbo).each do |role|
      expect(build(:user, role: role)).to_not be_valid
    end
  end

  it 'adds public services after creation' do
    10.times { create(:service, user_id: 0) }
    expect(create(:user).services.length).to eq(Service.published.count)
  end

  describe 'languages' do
    let(:user) { create(:user) }

    it 'has no languages if they have no texts' do
      expect(user.languages.count).to eq(0)
    end

    it 'has all languages from their texts' do
      2.times { create(:text, user: user) }
      expect(user.languages.count).to eq(2)
    end
  end
end
