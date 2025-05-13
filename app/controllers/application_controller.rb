# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!, unless: :guest_conversation_action?

  attr_reader :current_user

  private

  def authenticate_user!
    token = extract_token
    return render_unauthorized unless token

    begin
      decoded = decode_token(token)
      user_id = decoded[0]["sub"]
      user_type = decoded[0]["scp"]&.capitalize # "User", "Employee", or "Client"

      @current_user =
        case user_type
        when "User"
          User.find_by(id: user_id)
        when "Employee"
          Employee.find_by(id: user_id)
        when "Client"
          Client.find_by(id: user_id)
        else
          nil
        end

      render_unauthorized unless @current_user
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
      Rails.logger.error("Authentication error: #{e.message}")
      render_unauthorized
    end
  end

  def extract_token
    # Prefer Authorization header: "Bearer <token>"
    auth_header = request.headers["Authorization"]
    token = auth_header&.split("Bearer ")&.last

    # Fallback for Action Cable (query param: ?token=xxx)
    token ||= params[:token] if request.path == "/cable"

    token
  end

  def decode_token(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def guest_conversation_action?
    controller_name == "guest_conversations" && %w[create messages].include?(action_name)
  end

  # Optional helpers
  def employee?
    current_user.is_a?(Employee)
  end

  def user?
    current_user.is_a?(User)
  end

  def client?
    current_user.is_a?(Client)
  end
end
