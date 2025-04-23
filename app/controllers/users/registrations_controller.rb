class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :authenticate_user!

  def create
    super do |resource|
      if resource.persisted?
        # Calculate expiration based on remember_me
        expiration = params[:user][:remember_me] == "true" ? 30.days.to_i : 1.day.to_i
        # Manually create payload
        payload = {
          sub: resource.id,
          jti: resource.jti,
          scp: "user" # Scope, matching :user
        }
        token = JWT.encode(
          payload.merge(
            iat: Time.now.to_i,
            exp: Time.now.to_i + expiration,
            aud: nil
          ),
          Rails.application.credentials.secret_key_base,
          "HS256"
        )
        # Set the token in the Warden environment
        request.env["warden.jwt_auth.token"] = token
      end
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "Signed up successfully.",
        user: resource.as_json.merge(
          avatar_url: resource.avatar.attached? ? rails_blob_url(resource.avatar) : nil
        ),
        token: request.env["warden.jwt_auth.token"]
      }, status: :ok
    else
      Rails.logger.info "Validation errors: #{resource.errors.full_messages}"
      render json: { message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    user_params = params[:user] || ActionController::Parameters.new
    user_params.permit(:full_name, :email, :phone_number, :password, :password_confirmation, :avatar)
  end
end
