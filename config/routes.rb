Rails.application.routes.draw do
  get 'languageartworks/index'

  devise_for :users, controllers: { registrations: 'registration'}
  get 'statistics/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/cookies', to: 'welcome#cookie_policy'
  get '/home', to: 'welcome#home'
  get '/legal', to: 'welcome#legal_notice'

  # Categories
  get '/texts/:id/category', to: 'categories#edit', constraints: { id: /.+/ }, as: :edit_category
  get '/category', to: 'categories#autocomplete_text_category', as: :autocomplete_category_texts
  # Texts
  get '/texts', to: 'texts#index_language', as: :language_choice_texts
  get '/texts/:id', to: 'texts#show', constraints: { id: /[0-9]+/ }, as: :text
  get '/texts/:lang/new', to: 'texts#new', constraints: { lang: /.+/ }, as: :new_text
  get '/texts/:lang/archive', to: 'texts#index_hidden', constraints: { lang: /.+/ }, as: :archived_texts
  get '/texts/:lang/public', to: 'texts#index_public', constraints: { lang: /.+/ }, as: :public_texts
  get '/texts/:id/edit', to: 'texts#edit', constraints: { id: /.+/ }, as: :edit_text
  get '/texts/:id/copy', to: 'texts#copy', constraints: { id: /.+/ }, as: :copy_text
  get '/texts/:id/vocabulary', to: 'texts#vocabulary', constraints: { id: /.+/ }, as: :vocabulary_text
  get '/texts/:lang', to: 'texts#index', constraints: { lang: /.+/ }, as: :texts
  post '/texts/:lang', to: 'texts#create', constraints: { lang: /.+/ }
  resources :texts

  # Quick Reader
  get '/reader', to: 'reader#index_language', as: :language_choice_reader
  get '/reader/:lang', to: 'reader#index', constraints: { lang: /.+/ }, as: :reader
  post '/reader/:lang', to: 'reader#preview', constraints: { lang: /.+/ }

  # Words
  get '/words/:lang/:id/edit', to: 'words#edit', constraints: { id: /.+/ }, as: :edit_word
  get '/words/:lang/:id/sentence', to: 'words#sentence', constraints: { id: /.+/ }
  get '/words/:lang/:id/set', to: 'words#vocab_set', constraints: { id: /.+/ }, as: :set_vocab_word
  get '/words/:lang/:id/unset', to: 'words#vocab_unset', constraints: { id: /.+/ }, as: :unset_vocab_word
  get '/words/:lang/:id', to: 'words#show', constraints: { id: /.+/ }
  patch '/words/:id', to: 'words#update', constraints: { id: /.+/ }
  get '/words/:lang', to: 'words#index', as: :words
  get '/words', to: 'words#index_language', as: :language_choice_words

  # Vocabulary
  get '/vocabulary/:lang', to: 'vocabularies#index', constraints: { id: /.+/ }, as: :vocabulary
  get '/vocabulary', to: 'vocabularies#index_language', as: :language_choice_vocabulary

  # Dictation
  get '/dictation/:lang', to: 'dictations#index', constraints: { id: /.+/ }, as: :dictation
  get '/dictation', to: 'dictations#index_language', as: :dictations

  # Artworks
  get '/artworks', to: 'artworks#index_language', as: :language_choice_artwork
  get '/artworks/:lang/new', to: 'artworks#new', constraints: { lang: /[^0-9]+/ }, as: :new_artwork
  get '/artworks/:lang', to: 'artworks#index', constraints: { lang: /[^0-9]+/ }, as: :artworks_index
  resources :artworks

  # Other
  resources :languages
  resources :services do
    member do
      get :publish
      get :copy
    end
  end
  resources :compliments
  resources :replacements
  get "/settings/:page", to: "settings#show"
  get '/settings', to: 'settings#index'
  patch '/settings', to: 'settings#update'
  get '/statistics', to: 'statistics#index_language', as: :language_choice_statistics
  get '/statistics/:lang', to: 'statistics#index', constraints: { lang: /.+/ }, as: :statistics
  get '/u/:id', to: 'users#show'
  get '/u/:id/add', to: 'users#add'
  get '/u/:id/remove/:did', to: 'users#remove'
  get '/u', to: 'users#index'
  get "/help/:page", to: "help#show"
  get "/help", to: "help#index"
end
