json.value object.value
json.to_param object.to_param
json.words object.words_for_user(current_user) do |word|
  json.extract! word, :value, :language_id, :id
  json.language word.language.name
  json.notes word.notes.pluck(:value)
end
