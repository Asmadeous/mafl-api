# app/models/blog/post.rb

class Blog::Post < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  validates :status, inclusion: { in: %w[draft published] }
  validates :published_at, presence: true, if: -> { status == "published" }

  belongs_to :category, class_name: "Blog::Category", foreign_key: "category", optional: true
  belongs_to :employee, class_name: "Employee", foreign_key: "employee", optional: true
  has_many :posts_tags, class_name: "Blog::PostsTag", foreign_key: "post"
  has_many :tags, through: :posts_tags, class_name: "Blog::Tag"

  before_validation :generate_slug, unless: :slug?

  private

  def generate_slug
    self.slug = title.parameterize
  end
end
