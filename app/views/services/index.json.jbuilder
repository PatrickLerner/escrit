json.array! collection do |service|
  json.extract! service, :to_param, :name, :short_name, :url, :language_id
  json.language service.language.try(:name)
end
