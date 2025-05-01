class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :company_name, null: false
      t.string :email, default: "", null: false
      t.string :phone_number
      t.string :address
      t.string :billing_contact_name
      t.string :billing_contact_email
      t.string :billing_address
      t.string :tax_id
      t.string :service_type, default: "standard" # e.g., standard, express, freight
      t.text :notes
      t.uuid :employee_id, null: false # References the admin employee who created the client
      t.string :encrypted_password, default: "", null: false
      t.string :jti, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean :remember_me, default: false
      t.timestamps # Adds created_at and updated_at

      t.index [ :email ], unique: true
      t.index [ :jti ], unique: true
      t.index [ :reset_password_token ], unique: true
    end

    add_foreign_key :clients, :employees, column: :employee_id
  end
end
