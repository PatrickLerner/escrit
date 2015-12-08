class CreateOccurrences < ActiveRecord::Migration
  def up
    create_table :occurrences do |t|
      t.references :word, index: true
      t.references :text, index: true

      t.timestamps
    end

    Text.all.each { |text|
      text.update_occurrences
    }
  end

  def down
    drop_table :occurrences
  end
end
