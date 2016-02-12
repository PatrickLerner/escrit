module FeatureMacros
  def login_user
    let(:user) { create(:user) }

    before(:each) do
      user.extend(User::Real)
      user.real = true
      login_as user, scope: :user
    end
  end

  def login_admin
    let(:user) { create(:admin) }

    before(:each) do
      user.extend(User::Real)
      user.real = true
      login_as user, scope: :user
    end
  end
end
