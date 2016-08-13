module ControllerMacros
  def login_user
    let(:user) { create(:user) }

    before(:each) do
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end

  def request_json
    before :each do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    render_views
  end
end
