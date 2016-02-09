class AddIndexes < ActiveRecord::Migration
  def change
    add_index :notes, [:word_id, :user_id], unique: true
    add_index :occurrences, [:word_id, :text_id], unique: true
    add_index :words, [:value, :language_id], unique: true
  end
end
