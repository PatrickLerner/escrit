class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.string :short_name
      t.string :url
      t.references :language, index: true

      t.timestamps
    end
  end
end
