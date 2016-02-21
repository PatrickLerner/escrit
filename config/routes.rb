Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registration' }

  root 'welcome#index'

  get '/home',    to: 'welcome#home'
  get '/cookies', to: 'welcome#cookie_policy'
  get '/legal',   to: 'welcome#legal_notice'

  resources :services do
    member do
      get :publish
      get :copy
    end
  end

  get '/category',       to: 'categories#autocomplete_text_category'

  get '/texts',          to: 'texts#index_language'
  get '/reader',         to: 'reader#index_language'
  get '/words',          to: 'words#index_language'
  get '/statistics',     to: 'statistics#index_language'
  get '/vocabulary',     to: 'vocabulary#index_language'
  get '/dictation',      to: 'dictation#index_language'
  get '/artworks',       to: 'artworks#index_language'

  get '/help/:page',     to: 'help#show'
  get '/help',           to: 'help#index'

  get '/settings/:page', to: 'settings#show'
  get '/settings',       to: 'settings#index'
  patch '/settings',     to: 'settings#update'

  get '/u/:id',          to: 'users#show'
  get '/u/:id/add',      to: 'users#add'
  get '/u/:id/remove',   to: 'users#remove'
  get '/u',              to: 'users#index'

  resources :languages
  resources :compliments
  resources :replacements

  resources :languages, only: [], path: '' do
    resources :categories, only: [:edit]
    resources :artworks

    resources :texts do
      collection do
        get :public
        get :archive
      end

      member do
        get :vocabulary
        post :copy
      end
    end

    get :reader,      to: 'reader#index'
    post :reader,     to: 'reader#preview'

    get 'statistics', to: 'statistics#index'
    get 'vocabulary', to: 'vocabulary#index'
    get 'dictation',  to: 'dictation#index'

    resources :words, only: [:index, :show, :update] do
      collection do
        get :sentence
      end

      member do
        # TODO: make it post and delete instead
        get :vocab_set
        get :vocab_unset
      end
    end
  end
end
