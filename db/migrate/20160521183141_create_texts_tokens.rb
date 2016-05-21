class CreateTextsTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :texts_tokens, id: false do |t|
      t.references :text
      t.references :token
    end
  end
end
