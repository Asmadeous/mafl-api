class Employee < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :jwt_authenticatable,
         :rememberable,
         jwt_revocation_strategy: self

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, allow_blank: true
  validates :role, inclusion: { in: %w[staff admin] }
  validates :avatar, presence: true # Required avatar

  has_one_attached :avatar
  has_one_attached :full_picture
  has_many :posts, class_name: "Blog::Post", foreign_key: "employee_id"
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :conversations

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |employee|
      employee.full_name = auth.info.name
      employee.email = auth.info.email
      employee.password = Devise.friendly_token[0, 20]
      employee.phone_number = ""
      employee.role = "staff"
      employee.jti = SecureRandom.uuid
    end
  end

  def admin?
    role == "admin"
  end
end
