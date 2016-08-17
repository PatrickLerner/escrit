json.array!(collection) do |category|
  json.extract! category, :to_param, :value, :user_id, :language_id
  json.language category.language.name
  json.language_code category.language.code
end
