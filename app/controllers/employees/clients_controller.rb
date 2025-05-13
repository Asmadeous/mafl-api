class Employees::ClientsController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_client, only: :update

  def index
    clients = Client.where(employee_id: current_employee.id)
    render json: clients, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch clients: #{e.message}" }, status: :internal_server_error
  end

  def create
    client = Client.new(client_params.merge(employee_id: current_employee.id))
    if client.save
      render json: client, status: :created
    else
      render json: { error: client.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to create client: #{e.message}" }, status: :internal_server_error
  end

  def update
    if @client.update(client_params)
      render json: @client, status: :ok
    else
      render json: { error: @client.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update client: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end

  def set_client
    @client = Client.find_by(id: params[:id], employee_id: current_employee.id)
    render json: { error: "Client not found" }, status: :not_found unless @client
  end

  def client_params
    params.require(:client).permit(
      :company_name, :email, :phone_number, :address,
      :billing_contact_name, :billing_contact_email,
      :billing_address, :tax_id, :service_type, :notes
    )
  end
end
