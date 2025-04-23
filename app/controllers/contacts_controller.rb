class ContactsController < ApplicationController
  before_action :authenticate_user_or_employee!

  def index
    if current_user.is_a?(Employee)
      contacts = User.all.select(:id, :full_name)
    else
      contacts = Employee.all.select(:id, :full_name)
    end

    render json: contacts
  rescue => e
    Rails.logger.error("Error fetching contacts: #{e.message}")
    render json: { error: "Failed to load contacts" }, status: 500
  end

  private

  def authenticate_user_or_employee!
    # Custom auth logic that checks for either user or employee
    authenticate_user! || authenticate_employee!
  end
end
