class AddPublicToText < ActiveRecord::Migration
  def change
    add_column :texts, :public, :boolean
  end
end
