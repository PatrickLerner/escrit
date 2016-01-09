namespace :fix do
  desc "Fixes various things"
  task :notes => :environment do
    Word.all.each do |word|
      fix_me = word.notes.select { |note|
        word.notes.where(word_id: note.word_id, user_id: note.user_id).count > 1
      }.map { |note|
        note.user
      }.uniq
      fix_me.each { |user|
        # create new note from existing
        notes = word.notes.where(word_id: word.id, user_id: user.id)
        nn = notes[0]
        notes.each do |n|
          nn.value = n.value if nn.value != ''
          nn.rating = n.rating if n.rating > nn.rating
          if n.id != nn.id
            n.delete
          end
        end
        nn.save
        puts "Fix word " + word.value + ' ' + word.language.name + ' for ' + user.name
      }
    end
  end
end
