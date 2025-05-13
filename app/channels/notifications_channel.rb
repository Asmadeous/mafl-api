# app/channels/notifications_channel.rb
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    current = connection.current_user || connection.guest

    if current
      stream_key = current.is_a?(Guest) ? "notifications:guest:#{current.token}" : "notifications:#{current.class.name.downcase}:#{current.id}"
      stream_from stream_key
    else
      logger.warn("Subscription rejected: no valid user or guest")
      reject
    end
  end

  def unsubscribed
    # Cleanup if needed
  end
end
