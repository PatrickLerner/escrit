require 'rails_helper'

describe Replacement, type: :model do
  it 'has a valid factory' do
    expect(build(:replacement)).to be_valid
  end

  it { is_expected.to validate_presence_of(:value) }
end
