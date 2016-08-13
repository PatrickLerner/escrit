require 'rails_helper'

describe PagesController do
  render_views

  describe '#index' do
    it 'renders the html page' do
      get :index
      expect(response).to be_success
      expect(response.body).to include('ng-app="escrit"')
    end
  end
end
