class AddVocabularyToNote < ActiveRecord::Migration
  def change
    add_column :notes, :vocabulary, :boolean
    add_index :notes, :vocabulary
  end
end
