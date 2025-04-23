class Employees::ProfilesController < ApplicationController
  before_action :authenticate_employee!
  before_action :restrict_role_update, only: :update

  def show
    render json: {
      employee: current_employee.as_json.merge(
        avatar_url: current_employee.avatar.attached? ? rails_blob_url(current_employee.avatar) : nil,
        full_picture_url: current_employee.full_picture.attached? ? rails_blob_url(current_employee.full_picture) : nil
      )
    }, status: :ok
  end

  def update
    if current_employee.update(employee_params)
      render json: {
        message: "Profile updated successfully.",
        employee: current_employee.as_json.merge(
          avatar_url: current_employee.avatar.attached? ? rails_blob_url(current_employee.avatar) : nil,
          full_picture_url: current_employee.full_picture.attached? ? rails_blob_url(current_employee.full_picture) : nil
        )
      }, status: :ok
    else
      render json: { message: current_employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def admin_signed_in
    if employee_signed_in?
      render json: { 
        user: employee_json(current_employee, "employee")
      }, status: :ok
    else
      render json: { message: "Not authenticated" }, status: :unauthorized
    end
  end

  private

  def employee_json(record, type)
    {
      id: record.id,
      type: type,
      full_name: record.full_name,
      email: record.email,
      phone_number: record.phone_number,
      role: record.respond_to?(:role) ? record.role : nil,
      avatar_url: record.avatar.attached? ? rails_blob_url(record.avatar) : nil,
      full_picture: record.full_picture.attached? ? rails_blob_url(record.full_picture): nil
    }
  end

  def employee_params
    params.require(:employee).permit(:full_name, :phone_number, :role, :avatar, :full_picture)
  end

  def restrict_role_update
    if params[:employee][:role] && !current_employee.admin?
      render json: { message: "Only admins can update roles." }, status: :forbidden
    end
  end
end
