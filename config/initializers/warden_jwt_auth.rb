Warden::JWTAuth.configure do |config|
  # Set the secret for signing JWT tokens
  config.secret = Rails.application.credentials.secret_key_base
  # Define which requests trigger JWT token generation
  config.dispatch_requests = [
    [ "POST", %r{^/users/sign_in$} ],
    [ "POST", %r{^/users$} ],
    [ "POST", %r{^/employees/sign_in$} ],
    [ "POST", %r{^/employees$} ]
  ]
  # Define which requests revoke tokens
  config.revocation_requests = [
    [ "DELETE", %r{^/users/sign_out$} ],
    [ "DELETE", %r{^/employees/sign_out$} ]
  ]
  # Optional: Configure revocation strategy (if needed)
  # config.revocation_strategy = ->(token, _payload) { false }
end
