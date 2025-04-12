class DeviseCreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :full_name, null: false
      t.string :email, null: false, default: ""
      t.string :phone_number
      t.string :role, default: "staff" # Options: "staff", "admin"
      t.string :encrypted_password, null: false, default: ""
      t.string :jti, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.timestamps null: false
    end
    add_index :employees, :email, unique: true
    add_index :employees, :jti, unique: true
    add_index :employees, :reset_password_token, unique: true
  end
end
