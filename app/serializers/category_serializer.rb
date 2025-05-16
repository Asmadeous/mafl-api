class Blog::CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :description
end