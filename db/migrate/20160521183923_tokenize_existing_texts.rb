class TokenizeExistingTexts < ActiveRecord::Migration[5.0]
  def up
    Token.all.destroy_all
    Text.all.each(&:save)
  end
end
