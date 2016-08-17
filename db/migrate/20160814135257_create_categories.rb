class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :value
      t.references :user, foreign_key: true
      t.references :language, foreign_key: true

      t.timestamps
    end

    add_index :categories, [:value, :user_id, :language_id], unique: true
  end
end
