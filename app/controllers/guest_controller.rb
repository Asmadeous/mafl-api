# app/controllers/guest_conversations_controller.rb
class GuestConversationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create, :messages ]

  # POST /guest/conversations
  def create
    guest = Guest.create(name: guest_params[:name], email: guest_params[:email])
    unless guest.persisted?
      return render json: { errors: guest.errors.full_messages }, status: :unprocessable_entity
    end

    admin = Employee.where(role: "admin").order("RANDOM()").first
    unless admin
      return render json: { error: "No admin available" }, status: :service_unavailable
    end

    @conversation = Conversation.new(guest_id: guest.id, employee_id: admin.id)
    if @conversation.save
      render json: { conversation: @conversation, guest_token: guest.token }, status: :created
    else
      render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /guest/conversations/:id/messages
  def messages
    guest = Guest.find_by(token: params[:guest_token])
    unless guest
      return render json: { error: "Invalid guest token" }, status: :unauthorized
    end

    @conversation = Conversation.find_by(id: params[:id], guest_id: guest.id)
    unless @conversation
      return render json: { error: "Conversation not found" }, status: :not_found
    end

    @message = @conversation.messages.build(
      sender: guest,
      receiver: @conversation.employee,
      content: message_params[:content]
    )

    if @message.save
      ActionCable.server.broadcast("conversation:#{@conversation.id}", @message)
      render json: @message, status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def guest_params
    params.require(:guest).permit(:name, :email)
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
