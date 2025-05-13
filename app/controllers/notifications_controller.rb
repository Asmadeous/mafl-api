class NotificationsController < ApplicationController
  # before_action :authenticate_user_or_employee!

  def index
    @notifications = current_user_or_employee.notifications.order(created_at: :desc)

    # Map notifications to include necessary data
    notifications_data = @notifications.map do |notification|
      notification_hash = {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        read: notification.read,
        created_at: notification.created_at,
        type: notification.type,
        link: notification.link
      }

      # Only include conversation_id if the notification is related to a conversation
      if notification.notifiable_type == "Conversation" && notification.notifiable_id.present?
        notification_hash[:conversation_id] = notification.notifiable_id
      end

      notification_hash
    end

    render json: notifications_data
  end

  def read
    notification_id = params[:notification_id]
    notification = current_user_or_employee.notifications.find_by(id: notification_id)

    if notification
      notification.update(read: true)
      render json: { success: true }
    else
      render json: { error: "Notification not found" }, status: :not_found
    end
  end

  def mark_all_read
    current_user_or_employee.notifications.update_all(read: true)
    render json: { success: true }
  end
end
