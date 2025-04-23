class Notification < ApplicationRecord
  self.inheritance_column = :_type_disabled
  belongs_to :notifiable, polymorphic: true

  validates :type, inclusion: { in: %w[info success warning error] }, allow_nil: true
  validates :message, presence: true

  after_create :send_newsletter

  default_scope { order(created_at: :desc) }

  private

  def send_newsletter
    NotificationMailer.new_post_notification(self).deliver_later
  end
end
