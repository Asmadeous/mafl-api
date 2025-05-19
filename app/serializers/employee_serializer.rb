# app/serializers/employee_serializer.rb
class EmployeeSerializer
  include JSONAPI::Serializer
  set_type :employee
  attributes :id, :full_name, :role
end
