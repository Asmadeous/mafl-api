class AddStatusToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :status, :string, default: "pending", null: false
  end
end
