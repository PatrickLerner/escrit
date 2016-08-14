json.extract! object, *%i(to_param title content category language_id) +
                       %i(public user_id)
json.language object.language.name
json.word_count object.word_count
json.js_split_tokens js_split_tokens(object)
json.permissions permissions_for(object)
