class AddMissingIndexToActiveStorageAttachments < ActiveRecord::Migration[8.0]
  def change
    add_index :active_storage_attachments, [:record_type, :record_id, :name, :blob_id], unique: true, name: "index_active_storage_attachments_uniqueness"
  end
end
