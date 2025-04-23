# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, polymorphic: true
  belongs_to :receiver, polymorphic: true

  after_create :create_and_broadcast_notifications

  private

  def create_and_broadcast_notifications
    return unless conversation.user_id && conversation.employee_id
    return unless receiver_type.in?([ "User", "Employee" ]) && sender_type.in?([ "User", "Employee" ])

    user = conversation.user
    employee = conversation.employee
    return unless user && employee

    # Receiver notification
    receiver_notification = Notification.create!(
      message: "New message from #{sender_type}: #{content.truncate(50)}",
      title: "New Message",
      type: "info",
      notifiable: self,
      link: "/conversations/#{conversation_id}",
      read: false,
      notifiable_id: receiver_id,
      notifiable_type: receiver_type
    )

    # Sender notification
    sender_notification = Notification.create!(
      message: "You sent a message: #{content.truncate(50)}",
      title: "Message Sent",
      type: "info",
      notifiable: self,
      link: "/conversations/#{conversation_id}",
      read: false,
      notifiable_id: sender_id,
      notifiable_type: sender_type
    )

    # Broadcast to receiver
    receiver_stream_key = receiver_type == "User" ? "notifications:#{receiver_id}" : "notifications:employee:#{receiver_id}"
    ActionCable.server.broadcast(
      receiver_stream_key,
      {
        id: receiver_notification.id,
        title: receiver_notification.title,
        message: receiver_notification.message,
        type: receiver_notification.type,
        link: receiver_notification.link,
        read: receiver_notification.read,
        created_at: receiver_notification.created_at.iso8601,
        conversation_id: conversation_id
      }
    )

    # Broadcast to sender
    sender_stream_key = sender_type == "User" ? "notifications:#{sender_id}" : "notifications:employee:#{sender_id}"
    ActionCable.server.broadcast(
      sender_stream_key,
      {
        id: sender_notification.id,
        title: sender_notification.title,
        message: sender_notification.message,
        type: sender_notification.type,
        link: sender_notification.link,
        read: sender_notification.read,
        created_at: sender_notification.created_at.iso8601,
        conversation_id: conversation_id
      }
    )
  end
end
