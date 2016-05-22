json.extract! object, :to_param, :title, :content, :category
json.language object.language.name
json.word_count object.word_count
json.js_split_tokens js_split_tokens(object)
