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

  get "blog/posts", to: "blog/posts#index"
  get "blog/posts/:slug", to: "blog/posts#show"
  post "blog/posts", to: "blog/posts#create"
  put "blog/posts/:slug", to: "blog/posts#update"

  get "notifications", to: "notifications#index"
  put "notifications/:id", to: "notifications#update"

  get "up" => "rails/health#show", as: :rails_health_check
end
