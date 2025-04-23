
class RemoveSessionIdFromConversations < ActiveRecord::Migration[8.0]
  def change
    remove_column :conversations, :session_id
  end
end
