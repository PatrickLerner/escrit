class CreateCompliments < ActiveRecord::Migration
  def change
    create_table :compliments do |t|
      t.string :value
      t.references :language

      t.timestamps
    end
  end
end
