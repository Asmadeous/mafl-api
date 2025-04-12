class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      token = Warden::JWTAuth::UserEncoder.new.call(@user, :user, nil)
      render json: { message: "Signed in with Google.", user: @user, token: token }, status: :ok
    else
      render json: { message: "Google sign-in failed." }, status: :unprocessable_entity
    end
  end

  def failure
    render json: { message: "OAuth authentication failed." }, status: :unauthorized
  end
end
