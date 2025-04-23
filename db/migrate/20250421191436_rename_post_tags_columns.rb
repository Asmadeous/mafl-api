class RenamePostTagsColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :blog_posts_tags, :post, :post_id
    rename_column :blog_posts_tags, :tag, :tag_id
  end
end
