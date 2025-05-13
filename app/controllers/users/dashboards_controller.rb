class Users::DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    dashboard_data = {
      appointments: current_user.appointments.count,
      unread_notifications: current_user.notifications.where(read: false).count,
      recent_conversations: current_user.conversations.order(last_message_at: :desc).limit(5).map do |conv|
        {
          id: conv.id,
          employee: conv.employee.full_name,
          last_message_at: conv.last_message_at
        }
      end
    }
    render json: dashboard_data, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch dashboard data: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end