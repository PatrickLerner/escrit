class CreateLanguageArtworks < ActiveRecord::Migration
  def change
    create_table :language_artworks do |t|
      t.attachment :image
      t.references :language, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
