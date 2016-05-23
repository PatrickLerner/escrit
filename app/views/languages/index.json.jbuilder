json.array!(collection) do |language|
  json.extract! language, :to_param, :name, :code, :id
  json.url language_url(language, format: :json)
end
