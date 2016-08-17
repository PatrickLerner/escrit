class AddCategoryToTexts < ActiveRecord::Migration[5.0]
  def change
    rename_column :texts, :category, :legacy_category
    execute 'UPDATE texts SET category_id = NULL'
    add_foreign_key :texts, :categories
  end
end
