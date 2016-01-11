class AddVoiceToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :voice, :string
  end
end
