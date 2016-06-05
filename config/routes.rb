Rails.application.routes.draw do
  root 'pages#index'

  resources :languages
  resources :texts
  resources :tokens
  resources :words

  devise_scope :user do
    post   '/signup',        to: 'devise/registrations#create'
    get    '/signin',        to: 'devise/sessions#new'
    post   '/signin',        to: 'devise/sessions#create'
    delete '/signout',       to: 'devise/sessions#destroy'
    post   '/resetpassword', to: 'devise/passwords#create'
    patch  '/resetpassword', to: 'devise/passwords#update'
    put    '/resetpassword', to: 'devise/passwords#update'
  end
  # devise is super retarded and needs to be called on devise_for even
  # when it should not be necessairy. If you neglect to do this, then
  # you won't have `current_user` available anymore in your controllers.
  devise_for :users, skip: [:sessions, :registrations, :passwords]
end
