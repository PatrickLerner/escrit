json.extract! object, :value, :to_param, :language_id, :id
json.language object.language.name
json.notes object.notes.pluck(:value)
