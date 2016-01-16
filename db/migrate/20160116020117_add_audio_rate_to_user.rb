class AddAudioRateToUser < ActiveRecord::Migration
  def change
    add_column :users, :audio_rate, :integer
    User.all.update_all(audio_rate: 100)
  end
end
