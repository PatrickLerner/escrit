class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :value
      t.string :note
      t.integer :rating
      t.references :language

      t.timestamps
    end
  end
end
