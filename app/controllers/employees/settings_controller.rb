class Employees::SettingsController < ApplicationController
  before_action :authenticate_employee!

  def show
    settings = {
      full_name: current_employee.full_name,
      email: current_employee.email,
      phone_number: current_employee.phone_number,
      role: current_employee.role,
      remember_me: current_employee.remember_me
    }
    render json: settings, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch settings: #{e.message}" }, status: :internal_server_error
  end

  def update
    if current_employee.update(settings_params)
      render json: { message: "Settings updated successfully" }, status: :ok
    else
      render json: { error: current_employee.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update settings: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end

  def settings_params
    params.require(:settings).permit(:full_name, :email, :phone_number, :remember_me)
  end
end
