namespace :export do
  desc 'notes'
  task notes: :environment do
    Note.all.includes(:word).each do |note|
      fields = []
      fields << note.value
      fields << note.rating
      fields << note.user_id
      fields << note.word.value
      fields << note.word.language_id
      puts fields.join("\t")
    end
  end
end
