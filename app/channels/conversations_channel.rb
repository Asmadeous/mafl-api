# app/channels/conversations_channel.rb
class ConversationsChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])
    current = connection.current_user || connection.guest

    unless conversation && current && (
      conversation.user_id == current.id ||
      conversation.employee_id == current.id ||
      conversation.client_id == current.id ||
      conversation.guest_id == current.id
    )
      logger.warn("Subscription rejected: conversation_id=#{params[:conversation_id]}, entity_id=#{current&.id}, entity_type=#{current&.class}")
      reject
      return
    end

    stream_for conversation
  end

  def unsubscribed
    # Cleanup if needed
  end
end
