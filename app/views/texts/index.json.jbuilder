json.per_page collection.per_page
json.num_pages collection.num_pages
json.page params[:page] || 1
json.data collection do |text|
  json.extract! text, :to_param, :title, :category, :language_id
  json.language text.language.name
  json.url text_url(text, format: :json)
  json.word_count text.word_count
end
