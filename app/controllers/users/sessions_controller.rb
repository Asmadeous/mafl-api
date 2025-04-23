class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :authenticate_user!

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      resource.remember_me = params[:user][:remember_me] == "1" || params[:user][:remember_me] == true
      resource.save if resource.remember_me_changed?
      render json: { message: "Signed in successfully.", user: resource, token: request.env["warden-jwt_auth.token"] }, status: :ok
    else
      render json: { message: "Invalid credentials." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      current_user.update(jti: SecureRandom.uuid) # Revoke token
      render json: { message: "Signed out successfully." }, status: :ok
    else
      render json: { message: "Sign out failed." }, status: :unprocessable_entity
    end
  end
end
