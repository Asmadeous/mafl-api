# app/models/guest.rb
class Guest < ApplicationRecord
  has_many :conversations
  has_many :messages, as: :sender
  has_many :messages, as: :receiver
  has_many :notifications, as: :notifiable

  validates :token, presence: true, uniqueness: true
  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token ||= SecureRandom.hex(16)
  end
end
