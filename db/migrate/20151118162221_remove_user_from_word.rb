class RemoveUserFromWord < ActiveRecord::Migration
  def change
    remove_reference :words, :user, index: true
  end
end
