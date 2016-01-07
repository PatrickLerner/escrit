class RenameLanguageArtwortToArtwork < ActiveRecord::Migration
  def change
    rename_table :language_artworks, :artworks
  end
end
