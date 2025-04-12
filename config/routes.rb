# config/routes.rb
Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords"
  }, path: "", path_names: {
    sign_in: "users/sign_in",
    sign_out: "users/sign_out",
    registration: "users",
    password: "users/password"
  }

  devise_for :employees, controllers: {
    sessions: "employees/sessions",
    registrations: "employees/registrations",
    omniauth_callbacks: "employees/omniauth_callbacks",
    passwords: "employees/passwords"
  }, path: "", path_names: {
    sign_in: "employees/sign_in",
    sign_out: "employees/sign_out",
    registration: "employees",
    password: "employees/password"
  }

  get "users/profile", to: "users/profiles#show"
  put "users/profile", to: "users/profiles#update"
  get "employees/profile", to: "employees/profiles#show"
  put "employees/profile", to: "employees/profiles#update"

  # Blog routes
  scope :blog do
    resources :posts, only: [:index, :show, :create, :update], param: :slug, controller: "blog/posts" do
      get :tags, on: :member # /blog/posts/:slug/tags
    end
    get "categories", to: "blog/categories#index" # /blog/categories
    get "tags", to: "blog/tags#index" # /blog/tags
    get "related", to: "blog/posts#related" # /blog/related
  end

  get "notifications", to: "notifications#index"
  put "notifications/:id", to: "notifications#update"

  get "up" => "rails/health#show", as: :rails_health_check
end
