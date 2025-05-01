module Clients
  class SessionsController < Devise::SessionsController
    respond_to :json

    # POST /clients/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      resource.update(jti: SecureRandom.uuid) # Generate new jti for this session
      render json: {
        status: { code: 200, message: "Signed in successfully." },
        data: {
          client: resource.as_json(only: [ :id, :company_name, :email ]),
          token: resource.jti
        }
      }, status: :ok
    end

    # DELETE /clients/sign_out
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      if signed_out
        current_client.update(jti: nil) if current_client # Invalidate jti
        render json: { status: 200, message: "Signed out successfully." }, status: :ok
      else
        render json: { status: 401, message: "Couldn’t sign out." }, status: :unauthorized
      end
    end

    private

    def respond_with(_resource, _opts = {})
      render json: { status: 200, message: "Signed in." }, status: :ok
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
