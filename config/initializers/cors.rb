# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://www.mafllogistics.com", "http://www.mafllogistics.com", "https://mafllogistics.com", "http://mafllogistics.com"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      expose: [ "access-token", "expiry", "token-type", "uid", "client" ]
  end

  # For development environment
  if Rails.env.development?
    allow do
      origins "localhost:3000", "localhost:3001", "127.0.0.1:3000", "127.0.0.1:3001"

      resource "*",
        headers: :any,
        methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
        credentials: true,
        expose: [ "access-token", "expiry", "token-type", "uid", "client" ]
    end
  end
end
