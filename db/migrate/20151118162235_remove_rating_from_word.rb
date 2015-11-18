class RemoveRatingFromWord < ActiveRecord::Migration
  def change
    remove_column :words, :rating, :integer
  end
end
