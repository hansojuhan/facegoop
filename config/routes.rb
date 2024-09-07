Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "posts#index"

  # For Omniauth with Google
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    session: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :posts do
    # Singular resource, because each user only has one 'like'
    resource :like, module: :posts

    resources :comments, only: [ :new, :create ]
  end

  resources :users, only: :index do
    collection do
      get :followers
      get :following
    end

    # Paths for profile (there's only one per user)
    resource :profile, only: [:show, :edit, :update] do
      # Nested resource to remove profile image
      resource :profile_image, only: :destroy, module: :profiles
    end
  end

  resources :user_followers, only: [ :create, :destroy ] do
    member do
      post :accept
      delete :remove
    end
  end


end
