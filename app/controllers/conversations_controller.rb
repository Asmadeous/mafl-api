class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [ :show ]
  before_action :authorize_conversation, only: [ :create ]

  # Fetches all conversations the current user is part of
  def index
    conversations = Conversation
      .where("user_id = :id OR employee_id = :id", id: current_user.id)
      .order(updated_at: :desc) # [[2]] Recent conversations first

      render json: conversations.map { |c|
      {
        id: c.id,
        user_id: c.user_id,
        employee_id: c.employee_id,
        last_message_at: c.last_message_at&.iso8601,
        created_at: c.created_at.iso8601,
        updated_at: c.updated_at.iso8601
      }
    }, status: :ok
  end

  # Creates a conversation with proper authorization checks
  def create
    # Determine user role and validate parameters
    if current_user.employee?
      user = User.find_by(id: conversation_params[:user_id])
      return render_error("Invalid user ID") unless user
      conversation = Conversation.new(
        user_id: user.id,
        employee_id: current_user.id
      )
    else
      employee = Employee.find_by(id: conversation_params[:employee_id])
      return render_error("Invalid employee ID") unless employee
      conversation = Conversation.new(
        user_id: current_user.id,
        employee_id: employee.id
      )
    end

    if conversation.save
      render json: conversation, status: :created
    else
      render json: { error: conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Shows a conversation and marks notifications as read
  def show
    unless @conversation.user_id == current_user.id || @conversation.employee_id == current_user.id
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    # Mark notifications as read [[9]]
    notifications = Notification.where(
      notifiable_type: "Message",
      notifiable_id: @conversation.messages.pluck(:id),
      read: false
    )
    notifications.update_all(read: true)

    # Broadcast updates to the user's stream [[6]]
    stream_key = current_user.is_a?(Employee) ? "employee:#{current_user.id}" : "user:#{current_user.id}"
    notifications.each do |n|
      ActionCable.server.broadcast(
        stream_key,
        notification: n.as_json.merge(conversation_id: n.notifiable.conversation_id)
      )
    rescue => e
      Rails.logger.error "Broadcast failed: #{e.message}"
    end

    render json: {
      id: @conversation.id,
      messages: @conversation.messages.order(created_at: :desc).map do |m|
        {
          id: m.id,
          content: m.content,
          sender_id: m.sender_id,
          sender_type: m.sender_type,
          receiver_id: m.receiver_id,
          receiver_type: m.receiver_type,
          read: m.read,
          created_at: m.created_at.iso8601
        }
      end,
      last_message_at: @conversation.last_message_at&.iso8601
    }, status: :ok
  end

  private

  # Strong parameters to prevent mass assignment [[3]][[8]]
  def conversation_params
    params.permit(:user_id, :employee_id)
  end

  # Authorization check for creating conversations [[4]][[7]]
  def authorize_conversation
    unless current_user.employee? || conversation_params[:user_id] == current_user.id
      render_error("Unauthorized to create this conversation")
    end
  end

  # Error helper [[9]]
  def render_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end

  # Fetches the conversation or returns an error [[2]]
  def set_conversation
    @conversation = Conversation.find_by(id: params[:id])
    return if @conversation.present?

    render json: { error: "Conversation not found" }, status: :not_found
  end
end
