class CreateWords < ActiveRecord::Migration[5.0]
  def change
    create_table :words do |t|
      t.string :value
      t.references :language, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :words, [:value, :language_id, :user_id], unique: true
  end
end
