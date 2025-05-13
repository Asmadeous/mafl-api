# app/serializers/job_listing_serializer.rb
class JobListingSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :created_at, :updated_at
  belongs_to :employee, serializer: EmployeeSerializer
end
