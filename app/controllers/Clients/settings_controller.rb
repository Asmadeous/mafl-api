class Clients::SettingsController < ApplicationController
  before_action :authenticate_client!

  def show
    settings = {
      company_name: current_client.company_name,
      email: current_client.email,
      phone_number: current_client.phone_number,
      address: current_client.address,
      billing_contact_name: current_client.billing_contact_name,
      billing_contact_email: current_client.billing_contact_email,
      billing_address: current_client.billing_address,
      tax_id: current_client.tax_id,
      service_type: current_client.service_type
    }
    render json: settings, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch settings: #{e.message}" }, status: :internal_server_error
  end

  def update
    if current_client.update(settings_params)
      render json: { message: "Settings updated successfully" }, status: :ok
    else
      render json: { error: current_client.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update settings: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_client!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_client
  end

  def settings_params
    params.require(:settings).permit(
      :company_name, :email, :phone_number, :address,
      :billing_contact_name, :billing_contact_email,
      :billing_address, :tax_id, :service_type
    )
  end
end
