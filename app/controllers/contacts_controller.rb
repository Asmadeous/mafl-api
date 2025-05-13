class ContactsController < ApplicationController
  # before_action :authenticate_user!

  def index
    contacts = fetch_contacts
    render json: contacts.map { |contact| { id: contact.id, name: contact_name(contact), email: contact.email } }
  end

  private

  def fetch_contacts
    if current_user.is_a?(Employee) && current_user.role == "admin"
      User.all + Client.all
    else
      Employee.all
    end
  end

  def contact_name(contact)
    case contact
    when User, Employee
      contact.full_name
    when Client
      contact.company_name
    else
      ""
    end
  end

  def authenticate_user!
    # Assuming Devise or similar authentication; adjust based on your setup
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
      nil
    end
  end
end
