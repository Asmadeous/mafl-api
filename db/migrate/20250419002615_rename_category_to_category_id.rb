class RenameCategoryToCategoryId < ActiveRecord::Migration[8.0]
  def change
    rename_column :blog_posts, :category, :category_id
  end
end
