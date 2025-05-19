# app/serializers/job_listing_serializer.rb
class JobListingSerializer 
  include JSONAPI::Serializer
  set_type :job_listing

  # Define the attributes to be serialized
  attributes :id, :title, :description, :status, :created_at, :updated_at
  belongs_to :employee, serializer: EmployeeSerializer
end
