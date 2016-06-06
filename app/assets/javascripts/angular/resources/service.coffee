@escrit.factory 'Service', ['Resource', (Resource) ->
  (language_id) ->
    return Resource
      name_object: 'service'
      backend_path: "services/#{language_id}"
]
