class AddRoleToUser < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :role, :integer, default: 0, null: false
    User.where(admin: true).update_all(role: User.roles[:advisor])
    remove_column :users, :admin, :boolean
  end

  def down
    add_column :users, :admin, :boolean
    User.where.not(role: User.roles[:citizen]).update_all(admin: true)
    remove_column :users, :role, :integer
  end
end
