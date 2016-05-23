class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.references :word, foreign_key: true
      t.references :token, foreign_key: true
      t.integer :rating

      t.timestamps
    end
    add_index :entries, [:word_id, :token_id], unique: true
    drop_table :tokens_words
  end
end
