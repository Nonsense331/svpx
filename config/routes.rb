Svpx::Application.routes.draw do
  root 'home#welcome'

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'sign_out', to: 'sessions#destroy'

  get 'home', controller: 'home'
  get 'channels', controller: 'home'
  get 'update_subscriptions', controller: 'home'
  get 'update_activities', controller: 'home'

  resources :series do
    post :videos_from_regex, on: :collection
    get :channels_from_regex, on: :collection
    get :next_video, on: :member
  end

  resources :videos, except: [:new, :create, :edit, :update] do
    member do
      get :watched
      get :hate
      get :love
      get :increment_plays
    end
    collection do
      get :music
      get :random
    end
  end

  resources :channels do
    get :get_all_videos, on: :member
  end
end
