class AddVoiceRateToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :voice_rate, :string
  end
end
