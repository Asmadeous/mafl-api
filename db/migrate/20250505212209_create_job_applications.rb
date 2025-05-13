# db/migrate/20250505210809_create_job_applications.rb
class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :job_listing, type: :uuid, null: false, foreign_key: true
      t.references :applicant, type: :uuid, null: false, polymorphic: true
      t.references :reviewer, type: :uuid, foreign_key: { to_table: :employees }
      t.text :content, null: false
      t.string :status, null: false, default: 'pending'
      t.timestamps
    end
  end
end
