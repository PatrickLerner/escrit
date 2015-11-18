class RemoveNoteFromWord < ActiveRecord::Migration
  def change
    remove_column :words, :note, :string
  end
end
