class Blog::PostsTag < ApplicationRecord
  belongs_to :post, class_name: "Blog::Post"
  belongs_to :tag, class_name: "Blog::Tag"
end
