class Blog::PostsTag < ApplicationRecord
  belongs_to :post, class_name: "Blog::Post", foreign_key: "post_id"
  belongs_to :tag, class_name: "Blog::Tag", foreign_key: "tag_id"
end
