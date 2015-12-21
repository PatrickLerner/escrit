class UpdateAllWordCounts < ActiveRecord::Migration
  def up
    Text.all.each do |text|
      text.save
    end
  end

  def down
  end
end
