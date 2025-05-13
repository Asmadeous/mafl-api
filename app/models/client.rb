class Client < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  belongs_to :employee
  validates :employee_id, presence: true
  validates :jti, uniqueness: true, allow_nil: true

  # def self.from_omniauth(auth)
  #   # Find or create a client based on the email (uid)
  #   where(email: auth.uid).first_or_initialize do |client|
  #     client.company_name = auth.info.company_name || auth.info.name || "Unknown Company"
  #     client.email = auth.uid
  #     client.password = Devise.friendly_token[0, 20] if client.encrypted_password.blank? # Generate random password
  #     client.jti = SecureRandom.uuid
  #     # Assign a default employee_id (e.g., first admin employee)
  #     client.employee_id = Employee.find_by(role: "admin")&.id || Employee.first&.id
  #     client.save!
  #   end
  # end
end
