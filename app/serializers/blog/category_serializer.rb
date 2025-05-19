class Blog::CategorySerializer
  include JSONAPI::Serializer
   attributes :id, :name, :slug, :description
end
