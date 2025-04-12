class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "Signed up successfully.",
        user: resource.as_json.merge(
          avatar_url: resource.avatar.attached? ? rails_blob_url(resource.avatar) : nil
        ),
        token: request.env["warden-jwt_auth.token"]
      }, status: :ok
    else
      render json: { message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :phone_number, :avatar)
  end
end
