class Employees::DashboardsController < ApplicationController
  before_action :authenticate_employee!

  def show
    dashboard_data = {
      job_listings: current_employee.job_listings.count,
      appointments: current_employee.appointments.count,
      pending_job_applications: JobApplication.where(reviewer_id: current_employee.id, status: "pending").count,
      recent_appointments: current_employee.appointments.order(scheduled_at: :desc).limit(5).map do |appt|
        {
          id: appt.id,
          purpose: appt.purpose,
          scheduled_at: appt.scheduled_at
        }
      end
    }
    render json: dashboard_data, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch dashboard data: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end
end