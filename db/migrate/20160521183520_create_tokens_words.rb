class CreateTokensWords < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens_words, id: false do |t|
      t.references :token
      t.references :word
    end
  end
end
