require 'rails_helper'

describe Service, type: :model do
  it 'has a valid factory' do
    service = build(:service)
    expect(service).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:short_name) }
  it { is_expected.to validate_presence_of(:url) }

  it 'considers like objects equal' do
    s_one = create(:service, name: 'Service 1')
    s_two = create(:service, name: 'Service 2')
    expect(s_one).to_not eq(s_two)
    expect(s_one).to eq(s_one)

    s_one.name = s_two.name
    s_one.short_name = s_two.short_name
    s_one.url = s_two.url
    s_one.language = s_two.language
    expect(s_one).to eq(s_two)
  end
end
