class MessagesController < ApplicationController
  before_action :authenticate_user! # Assumes Devise or similar for API auth
  before_action :set_conversation
  before_action :set_message, only: [ :read ]

  def create
    unless @conversation.user_id && @conversation.employee_id
      render json: { error: "Conversation must have both user and employee" }, status: :unprocessable_entity
      return
    end

    unless @conversation.user_id == current_user.id || @conversation.employee_id == current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    message = @conversation.messages.new(
      sender: current_user,
      sender_type: current_user.class.name,
      receiver: current_user.is_a?(User) ? @conversation.employee : @conversation.user,
      receiver_type: current_user.is_a?(User) ? "Employee" : "User",
      content: message_params[:content]
    )

    if message.save
      # Broadcast message via ConversationsChannel
      ActionCable.server.broadcast(
        "conversations:#{@conversation.id}",
        {
          id: message.id,
          content: message.content,
          sender_id: message.sender_id,
          sender_type: message.sender_type,
          receiver_id: message.receiver_id,
          receiver_type: message.receiver_type,
          read: message.read,
          created_at: message.created_at.iso8601,
          conversation_id: @conversation.id
        }
      )
      render json: {
        id: message.id,
        content: message.content,
        sender_id: message.sender_id,
        sender_type: message.sender_type,
        receiver_id: message.receiver_id,
        receiver_type: message.receiver_type,
        read: message.read,
        created_at: message.created_at.iso8601,
        conversation_id: @conversation.id
      }, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def read
    if @message.receiver_id == current_user.id && @message.receiver_type == current_user.class.name
      @message.update!(read: true)
      # Broadcast read receipt
      ActionCable.server.broadcast(
        "conversations:#{@conversation.id}",
        {
          id: @message.id,
          content: @message.content,
          sender_id: @message.sender_id,
          sender_type: @message.sender_type,
          receiver_id: @message.receiver_id,
          receiver_type: @message.receiver_type,
          read: @message.read,
          created_at: @message.created_at.iso8601,
          conversation_id: @conversation.id
        }
      )
      render json: { message: "Message marked as read" }, status: :ok
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Conversation not found" }, status: :not_found
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Message not found" }, status: :not_found
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
