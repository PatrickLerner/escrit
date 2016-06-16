class AddLastOpenedAtToText < ActiveRecord::Migration[5.0]
  def up
    add_column :texts, :last_opened_at, :datetime
    Text.all.update_all('last_opened_at = updated_at')
  end

  def down
    remove_column :texts, :last_opened_at, :datetime
  end
end
