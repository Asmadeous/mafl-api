Rails.application.routes.draw do
  # Devise
  devise_for :users, controllers: {
    sessions:           "users/sessions",
    registrations:      "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords:          "users/passwords"
  }, path: "", path_names: {
    sign_in:  "users/sign_in",
    sign_out: "users/sign_out",
    registration: "users",
    password:     "users/password"
  }

  devise_for :employees, controllers: {
    sessions:           "employees/sessions",
    registrations:      "employees/registrations",
    omniauth_callbacks: "employees/omniauth_callbacks",
    passwords:          "employees/passwords"
  }, path: "", path_names: {
    sign_in:  "employees/sign_in",
    sign_out: "employees/sign_out",
    registration: "employees",
    password:     "employees/password"
  }

  devise_for :clients, controllers: {
    sessions: "clients/sessions",
    registrations: "clients/registrations",
    passwords: "clients/passwords",
    omniauth_callbacks: "clients/omniauth_callbacks"
  }, path: "", path_names: {
    sign_in:  "clients/sign_in",
    sign_out: "clients/sign_out",
    registration: "clients",
    password:     "clients/password"
  }

  # Profiles
  get  "users/profile",      to: "users/profiles#show"
  put  "users/profile",      to: "users/profiles#update"
  get  "employees/profile",  to: "employees/profiles#show"
  put  "employees/profile",  to: "employees/profiles#update"

  # Blog posts
  get  "blog/posts",          to: "blog/posts#index"
  get  "blog/posts/:slug",    to: "blog/posts#show"
  post "blog/posts",          to: "blog/posts#create"
  put  "blog/posts/:slug",    to: "blog/posts#update"
  get "blog/categories",      to: "blog/categories#index"
  get "blog/tags",            to: "blog/tags#index"

  # Newsletter subscription
  post "/newsletter/subscribe", to: "newsletter#subscribe"

  # contacts chat app
  get "/contacts", to: "contacts#index"

  # Notifications, messages
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ] do
      member do
        put :read
      end
    end
  end

  resources :notifications, only: [ :index ] do
    member do
      put :read
    end
    collection do
      put :mark_all_read
    end
  end

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check
  get "employees/admin_signed_in", to: "employees/profiles#admin_signed_in"

  # ActionCable with auth - mount last to ensure other routes take precedence
  mount ActionCable.server => "/cable"
end
