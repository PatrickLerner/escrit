class CreateReplacements < ActiveRecord::Migration
  def change
    create_table :replacements do |t|
      t.string :value
      t.string :replacement
      t.references :language, index: true

      t.timestamps
    end
  end
end
