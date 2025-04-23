
class CurrentUsersController < ApplicationController
  def show
    if user_signed_in?
      render json: user_json(current_user, "user"), status: :ok
    else
      render json: { message: "Not authenticated" }, status: :unauthorized
    end
  end

  private

  def user_json(record, type)
    {
      id: record.id,
      type: type,
      full_name: record.full_name,
      email: record.email,
      phone_number: record.phone_number,
      role: record.respond_to?(:role) ? record.role : nil,
      avatar_url: record.avatar.attached? ? rails_blob_url(record.avatar) : nil,
      # full_picture: record.full_picture.attached? ? rails_blob_url(record.full_picture): nil
    }
  end
end
