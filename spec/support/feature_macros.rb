module FeatureMacros
  def login_user
    let(:user) { create(:current_user) }

    before(:each) do
      login_as user, scope: :user
    end
  end

  def login_admin
    let(:user) { create(:current_admin) }

    before(:each) do
      login_as user, scope: :user
    end
  end
end
