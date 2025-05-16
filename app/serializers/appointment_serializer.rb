class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :scheduled_at, :purpose, :status, :created_at, :updated_at
  belongs_to :employee, serializer: EmployeeSerializer
  belongs_to :client, serializer: ClientSerializer, if: -> { object.client.present? }
  belongs_to :user, serializer: UserSerializer, if: -> { object.user.present? }
  # belongs_to :guest, serializer: GuestSerializer, if: -> { object.guest.present? }
end
