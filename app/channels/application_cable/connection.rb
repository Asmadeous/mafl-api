module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    identified_by :current_employee

    def connect
      self.current_user = find_verified_user
      self.current_employee = find_verified_employee
      reject_unauthorized_connection unless current_user || current_employee
    rescue StandardError => e
      logger.error "Connection error: #{e.message}"
      reject_unauthorized_connection
    end

    private

    def get_token
      # Extract token from the request parameters
      token = request.params[:token]
      logger.debug "Extracted token from params: #{token ? 'present' : 'missing'}"
      token
    end

    def find_verified_user
      token = get_token
      logger.debug "Attempting to verify user with token: #{token ? 'present' : 'missing'}"
      return nil unless token

      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
        logger.debug "Decoded user token: #{decoded_token.inspect}"
        if decoded_token[0]["scp"] == "user"  # Changed from sub_type to scp
          user = User.find_by(id: decoded_token[0]["sub"], jti: decoded_token[0]["jti"])
          logger.debug "User lookup result: #{user ? user.inspect : 'not found'}"
          user
        else
          logger.debug "Token scope is not user: #{decoded_token[0]["scp"]}"
          nil
        end
      rescue JWT::DecodeError => e
        logger.error "JWT decode error (User): #{e.message}"
        nil
      end
    end

    def find_verified_employee
      token = get_token
      logger.debug "Attempting to verify employee with token: #{token ? 'present' : 'missing'}"
      return nil unless token

      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
        logger.debug "Decoded employee token: #{decoded_token.inspect}"
        if decoded_token[0]["scp"] == "employee"  # Changed from sub_type to scp
          employee = Employee.find_by(id: decoded_token[0]["sub"], jti: decoded_token[0]["jti"])
          logger.debug "Employee lookup result: #{employee ? employee.inspect : 'not found'}"
          employee
        else
          logger.debug "Token scope is not employee: #{decoded_token[0]["scp"]}"
          nil
        end
      rescue JWT::DecodeError => e
        logger.error "JWT decode error (Employee): #{e.message}"
        nil
      end
    end
  end
end
