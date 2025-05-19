# app/serializers/client_serializer.rb
class ClientSerializer
  include JSONAPI::Serializer
  set_type :client
  attributes :id, :company_name, :email
end
