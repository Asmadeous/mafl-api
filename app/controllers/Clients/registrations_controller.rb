module Clients
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json
    before_action :authenticate_employee!, only: [ :create ]

    # POST /clients
    def create
      build_resource(sign_up_params.merge(employee_id: current_employee.id))
      resource.jti = SecureRandom.uuid
      if resource.save
        sign_in(resource_name, resource)
        render json: {
          status: { code: 200, message: "Client created successfully." },
          data: resource.as_json(only: [ :id, :company_name, :email, :employee_id ])
        }, status: :created
      else
        render json: {
          status: { code: 422, message: "Client could not be created.", errors: resource.errors.full_messages }
        }, status: :unprocessable_entity
      end
    end

    # PUT /clients
    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      if resource.update(account_update_params)
        render json: {
          status: { code: 200, message: "Client updated successfully." },
          data: resource.as_json(only: [ :id, :company_name, :email ])
        }, status: :ok
      else
        render json: {
          status: { code: 422, message: "Client could not be updated.", errors: resource.errors.full_messages }
        }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:client).permit(:company_name, :email, :password, :password_confirmation, :phone_number,
                                    :address, :billing_contact_name, :billing_contact_email, :billing_address,
                                    :tax_id, :service_type, :notes)
    end

    def account_update_params
      params.require(:client).permit(:company_name, :email, :phone_number, :address, :billing_contact_name,
                                    :billing_contact_email, :billing_address, :tax_id, :service_type, :notes)
    end
  end
end
