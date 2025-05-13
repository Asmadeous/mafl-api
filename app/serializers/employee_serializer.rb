# app/serializers/employee_serializer.rb
class EmployeeSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :role
end
