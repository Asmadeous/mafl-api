class Blog::PostSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :slug, :content, :excerpt, :featured_image, :status, :is_featured, :published_at, :author_name, :author_avatar_url
  belongs_to :category
  has_many :tags
  belongs_to :employee, serializer: ::EmployeeSerializer
end
