class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid  
      t.string :message
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
