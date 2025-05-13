class Employees::StaffController < ApplicationController
  before_action :authenticate_employee!
  before_action :ensure_admin!
  before_action :set_employee, only: :update

  def index
    employees = Employee.all
    render json: employees, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch employees: #{e.message}" }, status: :internal_server_error
  end

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: { error: employee.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to create employee: #{e.message}" }, status: :internal_server_error
  end

  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: { error: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update employee: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end

  def ensure_admin!
    render json: { error: "Forbidden: Admin access required" }, status: :forbidden unless current_employee.role == "admin"
  end

  def set_employee
    @employee = Employee.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

  def employee_params
    params.require(:employee).permit(:full_name, :email, :phone_number, :role)
  end
end
