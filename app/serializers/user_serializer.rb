# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer
  set_type :user

  # Define the attributes to be serialized
  # The attributes method is used to specify which attributes of the User model should be included in the serialized output.
  # In this case, we are including the id, full_name, and email attributes.
  attributes :id, :full_name, :email
end
