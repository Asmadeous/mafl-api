class Clients::DashboardsController < ApplicationController
  before_action :authenticate_client!

  def show
    dashboard_data = {
      appointments: current_client.appointments.count,
      conversations: current_client.conversations.count,
      recent_appointments: current_client.appointments.order(scheduled_at: :desc).limit(5).map do |appt|
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

  def authenticate_client!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_client
  end
end
