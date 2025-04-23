class Employees::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :authenticate_user!
  before_action :restrict_admin_signup, only: [ :create ]

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "Signed up successfully.",
        employee: resource.as_json.merge(
          avatar_url: resource.avatar.attached? ? rails_blob_url(resource.avatar) : nil,
          full_picture_url: resource.full_picture.attached? ? rails_blob_url(resource.full_picture) : nil
        ),
        token: request.env["warden-jwt_auth.token"]
      }, status: :ok
    else
      render json: { message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:employee).permit(:full_name, :email, :password, :password_confirmation, :phone_number, :role, :avatar, :full_picture)
  end

  def restrict_admin_signup
    if params[:employee][:role] == "admin"
      if Employee.exists?(role: "admin")
        unless current_employee&.admin?
          render json: { message: "Only admins can create admin accounts." }, status: :forbidden
        end
      end
    end
  end
end
