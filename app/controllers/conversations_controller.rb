class ConversationsController < ApplicationController
  before_action :authenticate_entity!
  before_action :set_conversation, only: [ :show ]
  before_action :authorize_conversation, only: [ :create ]

  # Fetches all conversations the current entity is part of
  def index
    conversations = Conversation
      .where(
        "user_id = :id OR employee_id = :id OR client_id = :id",
        id: current_entity.id
      )
      .order(updated_at: :desc) # Recent conversations first

    render json: conversations.map { |c|
      {
        id: c.id,
        user_id: c.user_id,
        employee_id: c.employee_id,
        client_id: c.client_id,
        last_message_at: c.last_message_at&.iso8601,
        created_at: c.created_at.iso8601,
        updated_at: c.updated_at.iso8601
      }
    }, status: :ok
  end

  # Creates a conversation with proper authorization checks
  def create
    if current_entity.is_a?(Employee)
      if conversation_params[:user_id].present?
        user = User.find_by(id: conversation_params[:user_id])
        return render_error("Invalid user ID") unless user
        conversation = Conversation.new(
          user_id: user.id,
          employee_id: current_entity.id
        )
      elsif conversation_params[:client_id].present?
        client = Client.find_by(id: conversation_params[:client_id])
        return render_error("Invalid client ID") unless client
        conversation = Conversation.new(
          client_id: client.id,
          employee_id: current_entity.id
        )
      else
        return render_error("Must specify user_id or client_id")
      end
    else # User or Client
      employee = Employee.find_by(id: conversation_params[:employee_id])
      return render_error("Invalid employee ID") unless employee
      conversation = Conversation.new(
        employee_id: employee.id,
        user_id: current_entity.is_a?(User) ? current_entity.id : nil,
        client_id: current_entity.is_a?(Client) ? current_entity.id : nil
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
    unless @conversation.user_id == current_entity.id ||
           @conversation.employee_id == current_entity.id ||
           @conversation.client_id == current_entity.id
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    # Mark notifications as read
    notifications = Notification.where(
      notifiable_type: "Message",
      notifiable_id: @conversation.messages.pluck(:id),
      read: false
    )
    notifications.update_all(read: true)

    # Broadcast updates to the entity's stream
    stream_key = case current_entity
    when Employee
                   "employee:#{current_entity.id}"
    when User
                   "user:#{current_entity.id}"
    when Client
                   "client:#{current_entity.id}"
    end
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

  # Strong parameters to prevent mass assignment
  def conversation_params
    params.permit(:user_id, :employee_id, :client_id)
  end

  # Authorization check for creating conversations
  def authorize_conversation
    if current_entity.is_a?(Employee)
      return if conversation_params[:user_id].present? || conversation_params[:client_id].present?
      render_error("Employee must specify user_id or client_id")
    elsif current_entity.is_a?(User)
      return if conversation_params[:user_id] == current_entity.id
      render_error("User can only create conversations for themselves")
    elsif current_entity.is_a?(Client)
      return if conversation_params[:client_id] == current_entity.id
      render_error("Client can only create conversations for themselves")
    else
      render_error("Unauthorized to create this conversation")
    end
  end

  # Error helper
  def render_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end

  # Fetches the conversation or returns an error
  def set_conversation
    @conversation = Conversation.find_by(id: params[:id])
    return if @conversation.present?

    render json: { error: "Conversation not found" }, status: :not_found
  end

  # Authenticate user, employee, or client
  def authenticate_entity!
    self.current_entity = current_user || current_employee || current_client
    unless current_entity
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  # Helper to access current authenticated entity
  attr_accessor :current_entity
end
