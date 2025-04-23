class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :jwt_authenticatable, :omniauthable,
         :rememberable,
         jwt_revocation_strategy: self,
         omniauth_providers: [ :google_oauth2 ]

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, allow_blank: true

  has_one_attached :avatar # Optional avatar

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :conversations

  def self.from_omniauth(auth)
    if auth.info.email.end_with?("@yourcompany.com")
      raise "Business email not allowed for users."
    end
    where(email: auth.info.email).first_or_create do |user|
      user.full_name = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.phone_number = ""
      user.jti = SecureRandom.uuid
    end
  end
end
