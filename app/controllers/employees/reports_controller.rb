class Employees::ReportsController < ApplicationController
  before_action :authenticate_employee!

  def index
    reports = {
      total_clients: Client.count,
      total_appointments: Appointment.count,
      total_job_applications: JobApplication.count,
      pending_applications: JobApplication.where(status: "pending").count
    }
    render json: reports, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to generate reports: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end
end
