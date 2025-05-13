# db/migrate/202505060003_create_appointments.rb
class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.references :client, type: :uuid, foreign_key: true
      t.references :user, type: :uuid, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.string :purpose, null: false
      t.timestamps
    end
  end
end
