class Employees::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Skip CSRF verification for OAuth callback, as it's handled by omniauth-rails_csrf_protection
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]
    unless auth.info.email.end_with?("@yourcompany.com")
      render json: { message: "Only business emails allowed for employees." }, status: :forbidden
      return
    end

    @employee = Employee.from_omniauth(auth)
    if @employee.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(@employee, :employee, nil)
      render json: { message: "Signed in with Google.", employee: @employee, token: token }, status: :ok
    else
      render json: { message: "Google sign-in failed." }, status: :unprocessable_entity
    end
  end

  # Handle failure (e.g., invalid state or CSRF token)
  def failure
    render json: { message: "OAuth authentication failed." }, status: :unauthorized
  end
end
