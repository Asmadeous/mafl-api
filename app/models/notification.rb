class Notification < ApplicationRecord
  self.inheritance_column = :_type_disabled
  belongs_to :notifiable, polymorphic: true

  validates :type, inclusion: { in: %w[info success warning error] }, allow_nil: true
  validates :message, presence: true

  after_create :send_newsletter

  default_scope { order(created_at: :desc) }

  private

  def send_newsletter
    # Only send newsletter for blog post notifications
    return unless notifiable_type == "BlogPost"

    recipient = notifiable_recipient
    if recipient && recipient.email.present?
      NotificationMailer.new_post_notification(self, recipient).deliver_later
    else
      Rails.logger.warn("Cannot send newsletter: invalid recipient or email for notification_id=#{id}, notifiable_type=#{notifiable_type}, notifiable_id=#{notifiable_id}")
    end
  end

  def notifiable_recipient
    case notifiable_type
    when "BlogPost"
      # For blog posts, send to the notifiable (User, Employee, or Client)
      case notifiable
      when User, Employee, Client
        notifiable
      else
        nil
      end
    else
      nil
    end
  end
end
