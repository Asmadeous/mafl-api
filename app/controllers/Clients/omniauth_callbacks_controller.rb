# module Clients
#   class OmniauthCallbacksController < Devise::OmniauthCallbacksController
#     def company_email
#       @client = Client.from_omniauth(request.env["omniauth.auth"])

#       if @client.persisted?
#         sign_in_and_redirect @client, event: :authentication
#         set_flash_message(:notice, :success, kind: "Company Email") if is_navigational_format?
#       else
#         session["devise.company_email_data"] = request.env["omniauth.auth"]
#         redirect_to new_client_session_path, alert: "Authentication failed."
#       end
#     end

#     def failure
#       redirect_to new_client_session_path, alert: "Authentication failed: #{omniauth_error}"
#     end

#     private

#     def omniauth_error
#       exception = env["omniauth.error"]
#       exception&.message || "Unknown error"
#     end
#   end
# end
