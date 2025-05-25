require 'sidekiq/web'

Rails.application.routes.draw do


  mount Sidekiq::Web => '/sidekiq'
  get "/healthz", to: "health#check", as: :health_check

  get "up" => "rails/health#show", as: :rails_health_check

  # Public endpoints
  post '/signup', to: 'users#create'
  post '/login',  to: 'auth#login'


  # —— Posts / Tags / Comments ——
  resources :posts do
    resources :comments, only: [:create, :update, :destroy, :index]
  end

  resources :tags, only: [:index, :show]  # (optional: if you want to list all tags)

  # Example:
  #   GET    /posts          → posts#index
  #   POST   /posts          → posts#create
  #   GET    /posts/:id      → posts#show
  #   PUT    /posts/:id      → posts#update
  #   DELETE /posts/:id      → posts#destroy
  #
  # Nested Comments:
  #   POST   /posts/:post_id/comments      → comments#create
  #   PUT    /posts/:post_id/comments/:id  → comments#update
  #   DELETE /posts/:post_id/comments/:id  → comments#destroy
  #   GET    /posts/:post_id/comments      → comments#index (optional)
  # Example of a protected endpoint:
  # get '/profile', to: 'profiles#show'
  #
  # (Any other controllers/actions you add later will automatically
  # require a valid JWT in `Authorization: Bearer <token>`.)


  # Defines the root path route ("/")
  # root "posts#index"
end