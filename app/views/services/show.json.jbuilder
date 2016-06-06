json.array! collection do |service|
  json.extract! service, :name, :short_name, :url
end
