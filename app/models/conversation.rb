# app/models/conversation.rb
class Conversation < ApplicationRecord
  belongs_to :user, optional: true  # Optional since user can be nil for session-based conversations
  belongs_to :employee             # Required (no `optional: true`)

  has_many :messages, dependent: :destroy

  validates :employee_id, presence: true
  validates :user_id, uniqueness: { scope: :employee_id }, if: -> { user_id.present? }
end
