# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    current = connection.current_user || connection.current_employee
    if current
      stream_from "notifications:#{current.class.name.downcase}:#{current.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Cleanup if needed
  end
end
