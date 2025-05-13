class MessagesController < ApplicationController
  before_action :authenticate_entity!
  before_action :set_conversation
  before_action :set_message, only: [ :read ]

  def create
    unless @conversation.user_id || @conversation.employee_id || @conversation.client_id
      render json: { error: "Conversation must have at least one participant" }, status: :unprocessable_entity
      return
    end

    unless @conversation.user_id == current_entity.id ||
           @conversation.employee_id == current_entity.id ||
           @conversation.client_id == current_entity.id
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    receiver = determine_receiver
    unless receiver
      render json: { error: "No valid receiver found" }, status: :unprocessable_entity
      return
    end

    message = @conversation.messages.new(
      sender: current_entity,
      sender_type: current_entity.class.name,
      receiver: receiver,
      receiver_type: receiver.class.name,
      content: message_params[:content]
    )

    if message.save
      # Update conversation's last_message_at
      @conversation.update(last_message_at: Time.current)

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

      # Create notification for receiver
      Notification.create(
        notifiable: message,
        message: "New message in conversation",
        title: "New Message",
        type: "info",
        link: "/conversations/#{@conversation.id}"
      )
      ActionCable.server.broadcast(
        "notifications:#{receiver.class.name.downcase}:#{receiver.id}",
        {
          message: "New message in conversation",
          title: "New Message",
          type: "info",
          link: "/conversations/#{@conversation.id}",
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
    if @message.receiver_id == current_entity.id && @message.receiver_type == current_entity.class.name
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

  def authenticate_entity!
    self.current_entity = current_user || current_employee || current_client
    unless current_entity
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  attr_accessor :current_entity

  def determine_receiver
    case current_entity
    when User
      @conversation.employee
    when Client
      @conversation.employee
    when Employee
      @conversation.user || @conversation.client
    end
  end
end
