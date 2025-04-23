class UpdateNotificationsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    add_column :notifications, :title, :string, default: "Notification"
    add_column :notifications, :type, :string, default: "info"
    add_column :notifications, :link, :string
    add_column :notifications, :notifiable_id, :uuid
    add_column :notifications, :notifiable_type, :string

    execute <<-SQL
      UPDATE notifications
      SET notifiable_id = user_id, notifiable_type = 'User'
      WHERE user_id IS NOT NULL
    SQL

    remove_column :notifications, :user_id
    remove_index :notifications, name: :index_notifications_on_user_id, if_exists: true
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end

  def down
    add_column :notifications, :user_id, :uuid
    add_index :notifications, :user_id, name: :index_notifications_on_user_id

    execute <<-SQL
      UPDATE notifications
      SET user_id = notifiable_id
      WHERE notifiable_type = 'User'
    SQL

    remove_column :notifications, :notifiable_id
    remove_column :notifications, :notifiable_type
    remove_column :notifications, :title
    remove_column :notifications, :type
    remove_column :notifications, :link
  end
end
