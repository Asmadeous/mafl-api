class Blog::Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  has_many :posts, class_name: "Blog::Post", foreign_key: "category_id"
end
