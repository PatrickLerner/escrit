class AddLanguageToText < ActiveRecord::Migration
  def change
    add_reference :texts, :language, index: true
  end
end
