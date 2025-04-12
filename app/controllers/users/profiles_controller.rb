class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      user: current_user.as_json.merge(
        avatar_url: current_user.avatar.attached? ? rails_blob_url(current_user.avatar) : nil
      )
    }, status: :ok
  end

  def update
    if current_user.update(user_params)
      render json: {
        message: "Profile updated successfully.",
        user: current_user.as_json.merge(
          avatar_url: current_user.avatar.attached? ? rails_blob_url(current_user.avatar) : nil
        )
      }, status: :ok
    else
      render json: { message: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :phone_number, :avatar)
  end
end
