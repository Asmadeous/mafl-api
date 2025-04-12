class Blog::Post < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :content, presence: true
  validates :status, inclusion: { in: %w[draft published] }

  belongs_to :category, class_name: "Blog::Category", foreign_key: "category_id"
  belongs_to :employee, foreign_key: "employee_id"
  has_many :posts_tags, class_name: "Blog::PostsTag", foreign_key: "post_id"
  has_many :tags, through: :posts_tags, class_name: "Blog::Tag"
end
