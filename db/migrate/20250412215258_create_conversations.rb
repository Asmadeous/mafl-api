# db/migrate/YYYYMMDDHHMMSS_create_conversations.rb
class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id
      t.uuid :employee_id, null: false
      t.string :session_id
      t.datetime :last_message_at
      t.timestamps
    end
    add_index :conversations, [:user_id, :employee_id], unique: true, where: "user_id IS NOT NULL"
    add_index :conversations, [:session_id, :employee_id], unique: true, where: "session_id IS NOT NULL"
    add_foreign_key :conversations, :users, column: :user_id
    add_foreign_key :conversations, :employees, column: :employee_id
  end
end
