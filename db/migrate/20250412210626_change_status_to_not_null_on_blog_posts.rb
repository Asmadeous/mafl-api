class ChangeStatusToNotNullOnBlogPosts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :blog_posts, :status, false, "draft"
  end
end
