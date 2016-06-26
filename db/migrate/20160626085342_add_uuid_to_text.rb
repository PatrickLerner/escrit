class AddUuidToText < ActiveRecord::Migration[5.0]
  def change
    add_column :texts, :uuid, :string
    add_index :texts, :uuid, unique: true
  end
end
