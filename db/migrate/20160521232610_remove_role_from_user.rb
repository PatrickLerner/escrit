class RemoveRoleFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :role, :integer
    add_column :users, :role, :string
    add_index :users, :role
  end
end
