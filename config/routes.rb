Rails.application.routes.draw do
  # Authentication (Devise)
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_for :employees, controllers: {
    sessions: "employees/sessions",
    registrations: "employees/registrations",
    passwords: "employees/passwords"
  }

  devise_for :clients, controllers: {
    sessions: "clients/sessions",
    registrations: "clients/registrations",
    passwords: "clients/passwords"
  }

  # User and Employee Profiles
  scope module: :users do
    get "users/profile", to: "profiles#show"
    put "users/profile", to: "profiles#update"
    get "users/dashboard", to: "dashboards#show"
    get "users/settings", to: "settings#show"
    put "users/settings", to: "settings#update"
  end

  scope module: :employees do
    get "employees/profile", to: "profiles#show"
    put "employees/profile", to: "profiles#update"
    get "employees/admin_signed_in", to: "profiles#admin_signed_in"
    get "employees/dashboard", to: "dashboards#show"
    get "employees/settings", to: "settings#show"
    put "employees/settings", to: "settings#update"
  end

  scope module: :clients do
    get "clients/dashboard", to: "dashboards#show"
    get "clients/settings", to: "settings#show"
    put "clients/settings", to: "settings#update"
  end

  # Blog Routes
  scope :blog, module: :blog do
    resources :posts, only: [ :index, :show, :create, :update ], param: :slug
    resources :categories, only: [ :index ]
    resources :tags, only: [ :index ]
  end

  # Newsletter Subscription
  post "newsletter/subscribe", to: "newsletter#subscribe"

  # Contacts Chat App
  get "contacts", to: "contacts#index"

  # Conversations and Messages
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ] do
      put :read, on: :member
    end
  end

  # Notifications
  resources :notifications, only: [ :index ] do
    put :read, on: :member
    put :mark_all_read, on: :collection
  end

  # Admin Routes (Employees)
  namespace :employees do
    resources :job_listings, only: [ :index, :show, :create, :update, :destroy ]
    resources :job_applications, only: [ :index, :show, :update ]
    resources :appointments, only: [ :index, :show, :create, :update, :destroy ] do
      member do
        patch :verify
        patch :reschedule
      end
    end
    resources :clients, only: [ :index, :create, :update ]
    resources :users, only: [ :index, :create, :update ]
    resources :staff, only: [ :index, :create, :update ]
    get "reports", to: "reports#index"
    get "export/clients", to: "exports#clients"
    get "export/users", to: "exports#users"
    get "export/appointments", to: "exports#appointments"
  end

  # Public Routes
  resources :job_listings, only: [ :index, :show ] do
    post "apply", to: "job_applications#create"
  end
  resources :appointments, only: [ :index, :show, :create ]

  # File Upload Endpoint
  post "uploads", to: "uploads#create"

  # Global Search Functionality
  get "search", to: "search#index"

  # ActionCable for Real-Time Features
  mount ActionCable.server => "/cable"
end

