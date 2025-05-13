class Users::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    settings = {
      full_name: current_user.full_name,
      email: current_user.email,
      phone_number: current_user.phone_number,
      remember_me: current_user.remember_me
    }
    render json: settings, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch settings: #{e.message}" }, status: :internal_server_error
  end

  def update
    if current_user.update(settings_params)
      render json: { message: "Settings updated successfully" }, status: :ok
    else
      render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update settings: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def settings_params
    params.require(:settings).permit(:full_name, :email, :phone_number, :remember_me)
  end
end
