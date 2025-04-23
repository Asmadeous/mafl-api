# app/services/notification_service.rb
class NotificationService
  def self.create_and_broadcast(recipient, notifiable, title, message, type = 'info', link = nil)
    notification = Notification.create(
      notifiable: notifiable,
      title: title,
      message: message,
      type: type,
      link: link,
      read: false
    )

    if notification.persisted?
      ActionCable.server.broadcast(
        "notifications:#{recipient.class.name.downcase}:#{recipient.id}",
        notification: {
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          link: notification.link,
          read: notification.read,
          notifiable_type: notification.notifiable_type,
          notifiable_id: notification.notifiable_id,
          created_at: notification.created_at.iso8601
        }
      )
    end

    notification
  end
end
