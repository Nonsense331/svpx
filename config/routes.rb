Svpx::Application.routes.draw do
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
  get 'love_video', controller: 'home'
  get 'increment_plays', controller: 'home'

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
end
