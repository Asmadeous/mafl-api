class ChangeUsersIdToUuid < ActiveRecord::Migration[8.0]
  def change
    # Add a new UUID column
    add_column :users, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false

    # Ensure uniqueness
    add_index :users, :uuid, unique: true

    # Update existing records (optional if you have data)
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users SET uuid = gen_random_uuid() WHERE uuid IS NULL;
        SQL
      end
    end

    # Remove the old id column and rename uuid to id
    remove_column :users, :id
    rename_column :users, :uuid, :id

    # Explicitly set the primary key
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end