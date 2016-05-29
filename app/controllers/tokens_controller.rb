class TokensController < ScaffoldController
  resource Token

  protected

  def load_object
    Token.find_or_initialize_by(value: params[:id])
  end

  def load_collection
    {
      user_id: current_user.id
    }
  end

  def word_from_data(data)
    Word.find_or_initialize_by(
      value: data['value'], user: current_user, language_id: data['language_id']
    )
  end

  def delete_removed_notes(word, all_notes)
    word.notes.where.not(value: all_notes).delete_all
  end

  def fix_remaining_notes(word, data)
    rem_notes = data['notes'].presence || []
    rem_notes -= word.notes.where(value: data['notes']).pluck(:value)
    rem_notes.each do |v|
      word.notes.build(value: v)
    end
  end

  def format_note_reference(note)
    {
      id: note.id,
      value: note.value
    }
  end

  def fixed_notes(word, data)
    delete_removed_notes(word, data['notes'])
    fix_remaining_notes(word, data)
    word.notes.map do |note|
      format_note_reference(note)
    end
  end

  def fix_note_references(word_from_data, data)
    data[:notes_attributes] = fixed_notes(word_from_data, data)
    data.delete(:notes)
    data
  end

  def format_entry_reference(entry, word_data)
    {
      id: entry.id,
      word_attributes: word_data,
      rating: entry.rating || 0
    }
  end

  def fix_entry_reference(word_from_data, word_data)
    entry = Entry.find_or_initialize_by(word: word_from_data, token: object)
    word_data[:id] = word_from_data.id if word_from_data.persisted?
    word_data[:user_id] = current_user.id
    format_entry_reference(entry, word_data)
  end

  def fix_entries_references(words_data)
    words_data.map do |word_data|
      word = word_from_data(word_data)
      word_data = fix_note_references(word, word_data)
      fix_entry_reference(word, word_data)
    end
  end

  def fix_word_references(params)
    params[:entries_attributes] = fix_entries_references(params[:words])
    params.delete(:words)
    params
  end

  def permitted_params
    p = params.require(:token).permit(:value, words: permitted_words_params)
    fix_word_references(p)
  end

  def permitted_words_params
    [:id, :value, :language_id, notes: []]
  end
end
