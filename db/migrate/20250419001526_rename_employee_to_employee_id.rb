class RenameEmployeeToEmployeeId < ActiveRecord::Migration[8.0]
  def change
    rename_column :blog_posts, :employee, :employee_id
  end
end
