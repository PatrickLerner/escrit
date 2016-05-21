class AddCodeToLanguage < ActiveRecord::Migration[5.0]
  def change
    add_column :languages, :code, :string
    add_index :languages, :code, unique: true
  end
end
