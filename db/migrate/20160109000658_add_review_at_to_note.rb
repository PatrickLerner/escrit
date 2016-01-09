class AddReviewAtToNote < ActiveRecord::Migration
  def change
    add_column :notes, :review_at, :datetime

    Note.all.each do |note|
      next_review = note.updated_at

      next_review += 1.day   if self.rating == 0
      next_review += 2.days  if self.rating == 1
      next_review += 5.days  if self.rating == 2
      next_review += 7.days  if self.rating == 3
      next_review += 13.days if self.rating == 4
      next_review += 31.days if self.rating == 5
      next_review += 31.days if self.rating == 6
          
      self.update(review_at: next_review)
    end
  end
end
