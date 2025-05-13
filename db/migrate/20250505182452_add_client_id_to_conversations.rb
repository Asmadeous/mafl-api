class AddClientIdToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :client_id, :uuid

    add_index :conversations, [ :client_id, :employee_id ],
              name: "index_conversations_on_client_id_and_employee_id",
              unique: true,
              where: "(client_id IS NOT NULL)"

    add_foreign_key :conversations, :clients, column: :client_id
  end
end
