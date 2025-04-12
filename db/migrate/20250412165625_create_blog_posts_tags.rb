class CreateBlogPostsTags < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_posts_tags do |t|
      t.uuid :post
      t.uuid :tag

      t.timestamps
    end
  end
end
