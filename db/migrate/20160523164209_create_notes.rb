class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.string :value
      t.references :word, foreign_key: true

      t.timestamps
    end
  end
end
