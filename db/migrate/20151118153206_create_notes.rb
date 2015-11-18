class CreateNotes < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.string :value
      t.integer :rating
      t.references :word, index: true
      t.references :user, index: true

      t.timestamps
    end

    Word.all.each do |w|
      words = Word.where value: w.value
      ref = words[0]
      notes = Note.where(word_id: ref.id, user_id: w.id)
      if notes.length == 0
        n = Note.new value: w.note, rating: w.rating, word: ref, user: w.user, created_at:w.created_at
        n.save
        words[1..-1].each do |dw|
          Note.where(word_id: dw.id).each do |no|
            no.word = ref
            no.save
          end
          dw.destroy
        end
      end
    end
  end

  def down
    Note.all.each do |n|
      w = n.word
      if n.word.user != nil and n.word.user.id != n.user_id
        w = Word.new value: n.word.value
      end
      w.note = n.value
      w.rating = n.rating
      w.created_at = n.created_at
      w.user = n.user
      w.save
    end

    drop_table :notes
  end
end
