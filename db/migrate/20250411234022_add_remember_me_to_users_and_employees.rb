class AddRememberMeToUsersAndEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :remember_me, :boolean, default: false
    add_column :employees, :remember_me, :boolean, default: false
  end
end
