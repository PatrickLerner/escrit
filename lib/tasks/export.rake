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

  task import: :environment do
    Entry.all.delete_all
    Note.all.delete_all
    Word.all.delete_all
    File.open('/Users/patrick/Desktop/1.txt').read.split("\n").each do |line|
      fields = line.split("\t")
      if fields[3].match(Word::WORD_REGEX).present? && fields[4].to_i <= 8 && !fields[0].blank? && fields[1].to_i != 6
        token = Token.find_or_initialize_by(value: fields[3])
        word = Word.new(value: fields[3], language_id: fields[4], user_id: fields[2])
        word.notes.build(value: fields[0])
        token.entries.build(word: word, rating: fields[1])
        token.save!
      else
        puts fields[3]
      end
    end
  end
end
