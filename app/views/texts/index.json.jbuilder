json.array!(collection) do |text|
  json.extract! text, :to_param, :title, :category
  json.language text.language.name
  json.url text_url(text, format: :json)
  json.word_count text.word_count
end
