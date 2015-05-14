class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :title
      t.text :content
      t.text :category
      t.boolean :completed
      t.integer :word_count

      t.timestamps
    end
  end
end
