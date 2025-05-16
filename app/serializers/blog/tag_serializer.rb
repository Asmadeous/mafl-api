class Blog::TagSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug
end