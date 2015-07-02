class AddHiddenToText < ActiveRecord::Migration
  def change
    add_column :texts, :hidden, :boolean
  end
end
