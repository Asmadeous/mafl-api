class Blog::Tag < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    has_many :posts_tags, class_name: "Blog::PostsTag", foreign_key: "tag_id"
    has_many :posts, through: :posts_tags, class_name: "Blog::Post"

    before_validation :generate_slug, unless: :slug?

    private

    def generate_slug
      self.slug = name.parameterize
    end
end
