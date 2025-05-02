require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class CompanyEmail < OmniAuth::Strategies::OAuth2
      option :name, :company_email

      # Configure client options (replace with your IdP's details)
      option :client_options, {
        site: "https://your-idp.example.com", # IdP base URL
        authorize_url: "/oauth/authorize",    # IdP authorization endpoint
        token_url: "/oauth/token"             # IdP token endpoint
      }

      # UID is the unique identifier (email in this case)
      uid { raw_info["email"] }

      # Info hash returned to OmniAuth
      info do
        {
          email: raw_info["email"],
          company_name: raw_info["company_name"] || raw_info["name"],
          name: raw_info["name"]
        }
      end

      # Extra data from the IdP
      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/api/user").parsed # Adjust endpoint to your IdP's user info API
      end

      # Validate the email domain
      def callback_phase
        unless valid_company_email?
          fail!(:invalid_email, error: "Email domain is not allowed.")
          return
        end
        super
      end

      private

      def valid_company_email?
        allowed_domains = ENV["ALLOWED_COMPANY_DOMAINS"]&.split(",") || [ "example.com" ]
        email = raw_info["email"]
        email && allowed_domains.any? { |domain| email.end_with?("@#{domain}") }
      end
    end
  end
end
