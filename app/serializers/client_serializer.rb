# app/serializers/client_serializer.rb
class ClientSerializer < ActiveModel::Serializer
  attributes :id, :company_name, :email
end
