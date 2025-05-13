# db/migrate/20250505210807_create_job_listings.rb
class CreateJobListings < ActiveRecord::Migration[8.0]
  def change
    create_table :job_listings, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, null: false, default: 'draft'
      t.timestamps
    end
  end
end
