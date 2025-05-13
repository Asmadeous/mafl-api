# app/models/conversation.rb
class Conversation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :client, optional: true
  belongs_to :guest, optional: true
  belongs_to :employee
  has_many :messages, dependent: :destroy

  validates :employee_id, presence: true
  validate :exactly_one_participant

  scope :for_participant, ->(participant) {
    where(user_id: participant.id, client_id: participant.id, guest_id: participant.id)
  }

  after_create :notify_employee

  private

  def exactly_one_participant
    participants = [ user_id, client_id, guest_id ].compact
    errors.add(:base, "Exactly one of user, client, or guest must be present") unless participants.size == 1
  end

  def notify_employee
    Notification.create(
      notifiable: employee,
      title: "New Conversation",
      message: "A new conversation has been started by #{participant_name}.",
      type: "info"
    )
  end

  def participant_name
    case
    when user then user.full_name
    when client then client.company_name
    when guest then guest.name || "Guest"
    else "Unknown"
    end
  end
end
