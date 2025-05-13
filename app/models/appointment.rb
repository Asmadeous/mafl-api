class Appointment < ApplicationRecord
  # Relationships
  belongs_to :employee
  belongs_to :client, optional: true
  belongs_to :user, optional: true
  belongs_to :guest, optional: true

  # Validations
  validates :employee_id, presence: true
  validates :scheduled_at, presence: true
  validates :purpose, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending approved rescheduled cancelled] }
  validate :scheduled_at_in_future
  validate :no_overlapping_appointments
  validate :only_one_participant

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rescheduled, -> { where(status: "rescheduled") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :for_participant, ->(participant) {
    where(
      user_id: participant.is_a?(User) ? participant.id : nil,
      client_id: participant.is_a?(Client) ? participant.id : nil,
      guest_id: participant.is_a?(Guest) ? participant.id : nil
    )
  }

  # Instance Methods
  def participant
    user || client || guest
  end

  private

  def scheduled_at_in_future
    if scheduled_at && scheduled_at <= Time.current
      errors.add(:scheduled_at, "must be in the future")
    end
  end

  def no_overlapping_appointments
    if Appointment.where(employee_id: employee_id)
                 .where(scheduled_at: scheduled_at)
                 .where.not(id: id)
                 .exists?
      errors.add(:scheduled_at, "conflicts with another appointment for this employee")
    end
  end

  def only_one_participant
    participant_count = [ user_id, client_id, guest_id ].compact.length
    if participant_count > 1
      errors.add(:base, "An appointment can only be associated with one participant (user, client, or guest)")
    end
  end
end
