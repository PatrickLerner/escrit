module FeatureMacros
  def login_user
    let(:user) { create(:user) }

    before(:each) do
      login_as user, scope: :user
    end
  end

  def login_admin
    let(:user) { create(:admin) }

    before(:each) do
      login_as user, scope: :user
    end
  end
end
