# db/migrate/20250421195444_rebuild_blog_tables_with_uuid.rb
class RebuildBlogTablesWithUuid < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    # Drop dependent tables first
    drop_table :blog_posts_tags, if_exists: true
    drop_table :blog_posts, if_exists: true
    drop_table :blog_categories, if_exists: true
    drop_table :blog_tags, if_exists: true

    # Recreate blog_categories
    create_table :blog_categories, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    # Recreate blog_tags
    create_table :blog_tags, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string :name
      t.string :slug
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    # Recreate blog_posts
    create_table :blog_posts, id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.text :excerpt
      t.uuid :employee_id
      t.uuid :category_id
      t.string :status, null: false
      t.boolean :is_featured
      t.datetime :published_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    # Recreate blog_posts_tags
    create_table :blog_posts_tags, force: :cascade do |t|
      t.uuid :post_id
      t.uuid :tag_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    # Add foreign keys
    add_foreign_key :blog_posts, :blog_categories, column: :category_id
    add_foreign_key :blog_posts, :employees, column: :employee_id
    add_foreign_key :blog_posts_tags, :blog_posts, column: :post_id
    add_foreign_key :blog_posts_tags, :blog_tags, column: :tag_id
  end
end
