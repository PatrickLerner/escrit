require 'rails_helper'

describe 'page rendering' do
  it 'returns the layout if route does not work' do
    get "/this/is/nonesense"
    expect(response).to be_success
    expect(response.body).to include('ng-app="escrit"')
  end

  it 'gives authorization error if not logged in' do
    get '/texts.json'
    expect(response.status).to eq(401)
  end
end
