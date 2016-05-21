require 'rails_helper'

describe Language, type: :model do
  it 'has a valid factory' do
    expect(build(:language)).to be_valid
  end

  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:code) }
  it { is_expected.to validate_length_of(:name).is_at_least(3) }
  it { is_expected.to validate_length_of(:code).is_equal_to(2) }

  it 'should always correctly parameterize as its code field' do
    language = build(:language)
    original_code = language.code
    expect(language.to_param).to eq(original_code)
    language.save
    expect(language.to_param).to eq(original_code)
    language.code = 'as'
    expect(language.to_param).to eq(original_code)
    language.save
    expect(language.to_param).to eq('as')
  end

  it { is_expected.to allow_value('ar').for(:code) }
  it { is_expected.to_not allow_value('AR').for(:code) }
end
