Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registration'}
  get 'statistics/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/cookies', to: 'welcome#cookie_policy'
  get '/home', to: 'welcome#home'
  get '/legal', to: 'welcome#legal_notice'

  resources :languages
  get '/texts/category(.:format)', to: 'texts#autocomplete_text_category', as: :autocomplete_text_category_texts
  get '/texts/:id', to: 'texts#show', :constraints => { :id => /[0-9]+/ }
  get '/texts/new', to: 'texts#new'
  get '/texts/:language/new', to: 'texts#new', :constraints => { :language => /.+/ }
  get '/texts/:language/archive', to: 'texts#index_hidden', :constraints => { :language => /.+/ }
  get '/texts/:language/public', to: 'texts#index_public', :constraints => { :language => /.+/ }
  get '/reader/:language', to: 'texts#reader', :constraints => { :language => /.+/ }
  get '/reader/', to: 'texts#reader'
  post '/reader/:language', to: 'texts#reader_preview', :constraints => { :language => /.+/ }
  get '/texts/:id/edit', to: 'texts#edit', :constraints => { :id => /.+/ }
  get '/texts/:id/copy', to: 'texts#copy', :constraints => { :id => /.+/ }
  get '/texts/:id/vocabulary', to: 'texts#vocabulary', :constraints => { :id => /.+/ }
  get '/texts/:language', to: 'texts#index', :constraints => { :language => /.+/ }
  resources :texts
  get '/words/:language/:id', to: 'words#show', :constraints => { :id => /.+/ }
  patch '/words/:id', to: 'words#update', :constraints => { :id => /.+/ }
  get '/words/:language', to: 'words#index'
  get '/words', to: 'words#index'
  resources :services
  resources :compliments
  resources :replacements
  get '/settings', to: 'settings#index'
  get '/statistics', to: 'statistics#index'
  get '/statistics/:language', to: 'statistics#index', :constraints => { :language => /.+/ }
  get '/u/:id', to: 'users#show'
  get '/u/:id/add', to: 'users#add'
  get '/u/:id/remove/:did', to: 'users#remove'
  get '/u', to: 'users#index'
  get "/help/:page" => "help#show"
  get "/help" => "help#index"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
