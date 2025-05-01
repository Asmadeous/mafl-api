class ConversationsChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])
    current = connection.current_user || connection.current_employee
    unless conversation && current && (conversation.user_id == current.id || conversation.employee_id == current.id)
      logger.warn("Subscription rejected: conversation_id=#{params[:conversation_id]}, user_id=#{current&.id}")
      reject
      return
    end
    stream_for conversation
  end

  def unsubscribed
    # Cleanup if needed
  end
end
