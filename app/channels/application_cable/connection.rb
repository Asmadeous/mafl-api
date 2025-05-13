# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    identified_by :guest

    def connect
      token = request.params[:token] || request.headers["Authorization"]&.split("Bearer ")&.last

      if token
        authenticate_with_token(token)
      else
        create_guest_connection
      end

      reject_unauthorized_connection unless current_user || guest
    end

    private

    def authenticate_with_token(token)
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: "HS256")
        user_id = decoded[0]["sub"]
        user_type = decoded[0]["scp"]&.capitalize

        case user_type
        when "User"
          self.current_user = User.find_by(id: user_id)
        when "Employee"
          self.current_user = Employee.find_by(id: user_id)
        when "Client"
          self.current_user = Client.find_by(id: user_id)
        end
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        self.guest = Guest.find_by(token: token)
      end
    end

    def create_guest_connection
      self.guest = Guest.create(name: "Guest_#{SecureRandom.hex(4)}")
      Rails.logger.info("Created guest connection: #{guest.token}") if guest.persisted?
    end
  end
end
