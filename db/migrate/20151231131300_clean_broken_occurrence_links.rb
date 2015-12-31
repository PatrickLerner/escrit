class CleanBrokenOccurrenceLinks < ActiveRecord::Migration
  def up
    Occurrence.all.each do |occurrence|
      t = Text.find_by id: occurrence.text_id
      if t == nil
        occurrence.delete
      end
    end
  end

  def down
  end
end
