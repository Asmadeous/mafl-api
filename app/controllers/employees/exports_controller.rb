class Employees::ExportsController < ApplicationController
  before_action :authenticate_employee!

  def clients
    clients = Client.all.map { |c| c.attributes.except("encrypted_password", "jti", "reset_password_token") }
    render json: clients, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to export clients: #{e.message}" }, status: :internal_server_error
  end

  def users
    users = User.all.map { |u| u.attributes.except("encrypted_password", "jti", "reset_password_token") }
    render json: users, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to export users: #{e.message}" }, status: :internal_server_error
  end

  def appointments
    appointments = Appointment.all.map { |a| a.attributes }
    render json: appointments, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to export appointments: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end
end
