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

  # Texts
  get '/texts', to: 'texts#index_language', as: :language_choice_texts
  get '/texts/category(.:format)', to: 'texts#autocomplete_text_category', as: :autocomplete_text_category_texts
  get '/texts/:id', to: 'texts#show', constraints: { id: /[0-9]+/ }, as: :text
  get '/texts/:language/new', to: 'texts#new', constraints: { language: /.+/ }, as: :new_text
  get '/texts/:language/archive', to: 'texts#index_hidden', constraints: { language: /.+/ }, as: :archived_texts
  get '/texts/:language/public', to: 'texts#index_public', constraints: { language: /.+/ }, as: :public_texts
  get '/texts/:id/edit', to: 'texts#edit', constraints: { id: /.+/ }, as: :edit_text
  get '/texts/:id/copy', to: 'texts#copy', constraints: { id: /.+/ }, as: :copy_text
  get '/texts/:id/vocabulary', to: 'texts#vocabulary', constraints: { id: /.+/ }, as: :vocabulary_text
  get '/texts/:language', to: 'texts#index', constraints: { language: /.+/ }, as: :texts
  post '/texts/:language', to: 'texts#create', constraints: { language: /.+/ }
  resources :texts

  # Quick Reader
  get '/reader', to: 'texts#reader_language', as: :language_choice_reader
  get '/reader/:language', to: 'texts#reader', constraints: { language: /.+/ }
  post '/reader/:language', to: 'texts#reader_preview', constraints: { language: /.+/ }

  # Words
  get '/words/:language/:id/edit', to: 'words#edit', constraints: { id: /.+/ }, as: :edit_word
  get '/words/:language/:id/sentence', to: 'words#sentence', constraints: { id: /.+/ }
  get '/words/:language/:id/set', to: 'words#vocab_set', constraints: { id: /.+/ }, as: :set_vocab_word
  get '/words/:language/:id/unset', to: 'words#vocab_unset', constraints: { id: /.+/ }, as: :unset_vocab_word
  get '/words/:language/:id', to: 'words#show', constraints: { id: /.+/ }
  patch '/words/:id', to: 'words#update', constraints: { id: /.+/ }
  get '/words/:language', to: 'words#index', as: :words
  get '/words', to: 'words#index_language'

  # Vocabulary
  get '/vocabulary/:language', to: 'vocabularies#index', constraints: { id: /.+/ }, as: :vocabulary
  get '/vocabulary', to: 'vocabularies#index_language', as: :vocabularies

  # Other
  resources :languages
  resources :services
  resources :compliments
  resources :languageartworks
  resources :replacements
  get '/settings', to: 'settings#index'
  get '/statistics', to: 'statistics#index_language'
  get '/statistics/:language', to: 'statistics#index', constraints: { language: /.+/ }
  get '/u/:id', to: 'users#show'
  get '/u/:id/add', to: 'users#add'
  get '/u/:id/remove/:did', to: 'users#remove'
  get '/u', to: 'users#index'
  get "/help/:page", to: "help#show"
  get "/help", to: "help#index"
end
