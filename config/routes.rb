Rails.application.routes.draw do
  root 'pages#index'

  allow_all_ids = { id: %r{[^/]+(?=\.html\z|\.json\z)|[^/]+} }
  read = [:index, :show]

  resources :languages, only: read
  resources :compliments, only: [:index]
  resources :texts
  resources :services
  resources :tokens, constraints: allow_all_ids
  resources :words, constraints: allow_all_ids, only: read

  devise_scope :user do
    post   '/signup',        to: 'registrations#create'
    get    '/signin',        to: 'sessions#new'
    post   '/signin',        to: 'sessions#create'
    delete '/signout',       to: 'sessions#destroy'
    post   '/resetpassword', to: 'devise/passwords#create'
    patch  '/resetpassword', to: 'devise/passwords#update'
    put    '/resetpassword', to: 'devise/passwords#update'
  end
  # devise is super retarded and needs to be called on devise_for even
  # when it should not be necessairy. If you neglect to do this, then
  # you won't have `current_user` available anymore in your controllers.
  devise_for :users, skip: [:sessions, :registrations, :passwords]

  get '(*url)' => 'pages#index'
end
