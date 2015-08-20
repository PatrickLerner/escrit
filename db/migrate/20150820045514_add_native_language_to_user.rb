class AddNativeLanguageToUser < ActiveRecord::Migration
  def change
    add_reference :users, :native_language, index: true
  end
end
