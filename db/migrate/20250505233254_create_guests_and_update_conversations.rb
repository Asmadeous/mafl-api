# db/migrate/202505060004_create_guests_and_update_conversations.rb
class CreateGuestsAndUpdateConversations < ActiveRecord::Migration[8.0]
  def change
    # Create guests table for unregistered users
    create_table :guests, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :name, default: "Guest"
      t.string :email
      t.string :token, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index :token, unique: true
    end

    # Add guest_id to conversations
    add_column :conversations, :guest_id, :uuid
    add_index :conversations, [ :guest_id, :employee_id ], unique: true, where: "(guest_id IS NOT NULL)", name: "index_conversations_on_guest_id_and_employee_id"
    add_foreign_key :conversations, :guests, column: :guest_id
  end
end
