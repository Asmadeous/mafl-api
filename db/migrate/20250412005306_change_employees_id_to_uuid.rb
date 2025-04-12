class ChangeEmployeesIdToUuid < ActiveRecord::Migration[8.0]
  def change
    # Add a new UUID column
    add_column :employees, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false

    # Ensure uniqueness
    add_index :employees, :uuid, unique: true

    # Update existing records (optional if you have data)
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE employees SET uuid = gen_random_uuid() WHERE uuid IS NULL;
        SQL
      end
    end

    # Remove the old id column and rename uuid to id
    remove_column :employees, :id
    rename_column :employees, :uuid, :id

    # Explicitly set the primary key
    execute "ALTER TABLE employees ADD PRIMARY KEY (id);"
  end
end
