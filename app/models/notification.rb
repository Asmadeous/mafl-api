class Notification < ApplicationRecord
  belongs_to :user
  validates :message, presence: true
  after_create :send_newsletter
  default_scope { order(created_at: :desc) }

  private

  def send_newsletter
    NotificationMailer.new_post_notification(self).deliver_later
  end
end
