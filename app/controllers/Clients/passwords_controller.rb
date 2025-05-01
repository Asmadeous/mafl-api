module Clients
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    # POST /clients/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      if successfully_sent?(resource)
        render json: { status: 200, message: "Reset password instructions sent." }, status: :ok
      else
        render json: {
          status: 422,
          message: "Could not send reset instructions.",
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # PUT /clients/password
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      if resource.errors.empty?
        resource.update(jti: SecureRandom.uuid) # Refresh jti after password reset
        render json: { status: 200, message: "Password reset successfully." }, status: :ok
      else
        render json: {
          status: 422,
          message: "Could not reset password.",
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    private

    def resource_params
      params.require(:client).permit(:email, :reset_password_token, :password, :password_confirmation)
    end
  end
end
