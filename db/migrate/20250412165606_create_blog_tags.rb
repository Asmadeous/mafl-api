class CreateBlogTags < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_tags do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
