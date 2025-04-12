class UpdateActiveStorageAttachmentsRecordIdToUuid < ActiveRecord::Migration[8.0]
  def up
    # Add a new UUID column
    add_column :active_storage_attachments, :new_record_id, :uuid

    # Populate new_record_id based on record_type and old record_id
    ActiveStorage::Attachment.find_each do |attachment|
      case attachment.record_type
      when "User"
        user = User.find_by(id: attachment.record_id)
        attachment.update_column(:new_record_id, user.id) if user
      when "Employee"
        employee = Employee.find_by(id: attachment.record_id)
        attachment.update_column(:new_record_id, employee.id) if employee
        # Add other record_types if applicable
      end
    end

    # Remove the old record_id column and rename new_record_id
    remove_column :active_storage_attachments, :record_id
    rename_column :active_storage_attachments, :new_record_id, :record_id

    # Ensure record_id is not null
    change_column_null :active_storage_attachments, :record_id, false
  end

  def down
    # Revert to bigint for rollback
    add_column :active_storage_attachments, :new_record_id, :bigint

    # Populate based on UUIDs (inverse mapping may not be possible)
    ActiveStorage::Attachment.find_each do |attachment|
      case attachment.record_type
      when "User"
        user = User.find_by(id: attachment.record_id)
        attachment.update_column(:new_record_id, user.id.to_i) if user
      when "Employee"
        employee = Employee.find_by(id: attachment.record_id)
        attachment.update_column(:new_record_id, employee.id.to_i) if employee
      end
    end

    remove_column :active_storage_attachments, :record_id
    rename_column :active_storage_attachments, :new_record_id, :record_id
    change_column_null :active_storage_attachments, :record_id, false
  end
end
