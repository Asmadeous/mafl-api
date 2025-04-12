class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    notifications = current_user.notifications
    render json: { notifications: notifications }, status: :ok
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    render json: { message: "Notification marked as read.", notification: notification }, status: :ok
  end
end
