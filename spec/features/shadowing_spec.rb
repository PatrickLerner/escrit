require 'rails_helper'

describe 'shadowing for admins' do
  login_admin

  let(:normal_user) { create(:user) }

  it 'allows shadowing' do
    visit home_path + "?u=#{normal_user.id}"

    expect(page).to have_content normal_user.name
    expect(page).to_not have_content user.name
  end
end

describe 'shadowing for normal users' do
  login_user

  let(:normal_user) { create(:user) }

  it 'does not allow shadowing' do
    visit home_path + "?u=#{normal_user.id}"

    expect(page).to_not have_content normal_user.name
    expect(page).to have_content user.name
  end
end
