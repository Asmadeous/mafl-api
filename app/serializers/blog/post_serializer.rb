class Blog::PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :slug, :content, :excerpt, :featured_image, :status, :is_featured, :published_at, :author_name, :author_avatar_url
  belongs_to :category, serializer: Blog::CategorySerializer
  has_many :tags, serializer: Blog::TagSerializer

  def author_name
    object.employee&.full_name
  end

  def author_avatar_url
    object.employee&.avatar&.attached? ? Rails.application.routes.url_helpers.rails_blob_url(object.employee.avatar, host: object.request.host) : nil
  end
end
