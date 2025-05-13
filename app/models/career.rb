# app/models/career.rb
class Career
  # JobListing represents a job posting created and managed by admin employees
  class JobListing < ApplicationRecord
    self.table_name = "job_listings"

    belongs_to :employee
    has_many :job_applications, dependent: :destroy

    validates :title, :description, :status, presence: true
    validates :status, inclusion: { in: %w[open closed draft] }
    validate :employee_must_be_admin

    scope :active, -> { where(status: "open") }

    after_create :notify_users_of_new_listing

    private

    def employee_must_be_admin
      errors.add(:employee, "must be an admin") unless employee&.role == "admin"
    end

    def notify_users_of_new_listing
      User.find_each do |user|
        Notification.create(
          notifiable: user,
          title: "New Career Opportunity",
          message: "A new job listing '#{title}' is now open!",
          type: "info"
        )
      end
    end
  end

  # JobApplication represents an application submitted by a user or client
  class JobApplication < ApplicationRecord
    self.table_name = "job_applications"

    belongs_to :job_listing
    belongs_to :applicant, polymorphic: true # Can be User or Client
    belongs_to :reviewer, class_name: "Employee", optional: true

    validates :content, presence: true
    validates :status, inclusion: { in: %w[pending reviewed accepted rejected] }
    validate :reviewer_must_be_admin, if: -> { reviewer.present? }

    after_create :notify_applicant_of_submission
    after_create :notify_admins_of_new_application
    after_update :notify_applicant_of_status_change, if: :status_changed?

    private

    def reviewer_must_be_admin
      errors.add(:reviewer, "must be an admin") unless reviewer&.role == "admin"
    end

    def notify_applicant_of_submission
      Notification.create(
        notifiable: applicant,
        title: "Job Application Submitted",
        message: "Your application for '#{job_listing.title}' has been submitted.",
        type: "info"
      )
    end

    def notify_admins_of_new_application
      Employee.where(role: "admin").find_each do |admin|
        Notification.create(
          notifiable: admin,
          title: "New Job Application",
          message: "A new application for '#{job_listing.title}' has been submitted by #{applicant_name}.",
          type: "info"
        )
      end
    end

    def notify_applicant_of_status_change
      message = case status
      when "reviewed"
                  "Your application for '#{job_listing.title}' is under review."
      when "accepted"
                  "Congratulations! Your application for '#{job_listing.title}' has been accepted."
      when "rejected"
                  "Your application for '#{job_listing.title}' has been rejected."
      else
                  "Your application status for '#{job_listing.title}' has changed to #{status}."
      end

      Notification.create(
        notifiable: applicant,
        title: "Job Application Update",
        message: message,
        type: status == "accepted" ? "success" : (status == "rejected" ? "error" : "info")
      )
    end

    def applicant_name
      case applicant
      when User
        applicant.full_name
      when Client
        applicant.company_name
      else
        "Unknown Applicant"
      end
    end
  end
end
