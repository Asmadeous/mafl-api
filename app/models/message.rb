# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, polymorphic: true
  belongs_to :receiver, polymorphic: true

  after_create :create_and_broadcast_notifications

  private

  def create_and_broadcast_notifications
    # Ensure conversation has valid participants
    unless conversation.user_id || conversation.employee_id || conversation.client_id || conversation.guest_id
      Rails.logger.warn("No valid participants for notification: conversation_id=#{conversation_id}")
      return
    end

    # Ensure sender and receiver types are valid
    valid_types = %w[User Employee Client Guest]
    unless sender_type.in?(valid_types) && receiver_type.in?(valid_types)
      Rails.logger.warn("Invalid sender/receiver type: sender_type=#{sender_type}, receiver_type=#{receiver_type}")
      return
    end

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
    receiver_stream_key = case receiver_type
    when "User"
                           "notifications:user:#{receiver_id}"
    when "Employee"
                           "notifications:employee:#{receiver_id}"
    when "Client"
                           "notifications:client:#{receiver_id}"
    when "Guest"
                           "notifications:guest:#{receiver.token}"
    end
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
    sender_stream_key = case sender_type
    when "User"
                         "notifications:user:#{sender_id}"
    when "Employee"
                         "notifications:employee:#{sender_id}"
    when "Client"
                         "notifications:client:#{sender_id}"
    when "Guest"
                         "notifications:guest:#{sender.token}"
    end
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
  rescue StandardError => e
    Rails.logger.error("Failed to create/broadcast notifications: #{e.message}")
  end
end
