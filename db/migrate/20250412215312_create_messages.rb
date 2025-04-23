# db/migrate/YYYYMMDDHHMMSS_create_messages.rb
class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :conversation, type: :uuid, null: false, foreign_key: true
      t.uuid :sender_id, null: false
      t.string :sender_type, null: false
      t.uuid :receiver_id, null: false
      t.string :receiver_type, null: false
      t.text :content, null: false
      t.boolean :read, default: false, null: false
      t.timestamps
    end
    add_index :messages, [ :sender_id, :sender_type ]
    add_index :messages, [ :receiver_id, :receiver_type ]
  end
end
