class Employees::UsersController < ApplicationController
  before_action :authenticate_employee!
  before_action :set_user, only: :update

  def index
    users = User.all
    render json: users, status: :ok
  rescue StandardError => e
    render json: { error: "Failed to fetch users: #{e.message}" }, status: :internal_server_error
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to create user: #{e.message}" }, status: :internal_server_error
  end

  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Failed to update user: #{e.message}" }, status: :internal_server_error
  end

  private

  def authenticate_employee!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_employee
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :phone_number)
  end
end
