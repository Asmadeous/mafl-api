# db/migrate/20250421000002_use_uuid_for_blog_posts_and_categories.rb
class UseUuidForBlogPostsAndCategories < ActiveRecord::Migration[8.0]
  def change
    # Enable uuid-ossp extension if not already enabled
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    # Change blog_posts.id to uuid
    change_table :blog_posts do |t|
      # Remove existing primary key
      execute 'ALTER TABLE blog_posts DROP CONSTRAINT blog_posts_pkey;'
      # Change id to uuid
      t.change :id, :uuid, default: -> { 'gen_random_uuid()' }, primary_key: true
      # Ensure category_id remains uuid
      t.change :category_id, :uuid
      # Remove featured_image string column
      t.remove :featured_image
    end

    # Change blog_categories.id to uuid
    change_table :blog_categories do |t|
      # Remove existing primary key
      execute 'ALTER TABLE blog_categories DROP CONSTRAINT blog_categories_pkey;'
      # Change id to uuid
      t.change :id, :uuid, default: -> { 'gen_random_uuid()' }, primary_key: true
    end

    # Add foreign key constraints
    add_foreign_key :blog_posts, :blog_categories, column: :category_id
    add_foreign_key :blog_posts, :employees, column: :employee_id
  end
end