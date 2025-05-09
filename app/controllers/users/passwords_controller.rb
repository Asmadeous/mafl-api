class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!
  respond_to :json

  # POST /users/password - Send reset instructions
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      render json: { message: "Password reset instructions sent." }, status: :ok
    else
      render json: { message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /users/password - Reset password with token
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      render json: { message: "Password reset successfully." }, status: :ok
    else
      render json: { message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email, :reset_password_token, :password, :password_confirmation)
  end
end
