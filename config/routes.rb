Svpx::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#welcome'

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'sign_out', to: 'sessions#destroy'

  get 'home', controller: 'home'
  get 'channels', controller: 'home'
  get 'update_subscriptions', controller: 'home'
  get 'update_activities', controller: 'home'
  get 'music', controller: 'home'
  get 'random_video', controller: 'home'
  get 'hate_video', controller: 'home'

  resources :series do
    post :videos_from_regex, on: :collection
    get :next_video, on: :member
  end

  resources :videos, except: [:new, :create, :edit, :update] do
    get :watched, on: :member
  end

  resources :channels do
    get :get_all_videos, on: :member
  end

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
