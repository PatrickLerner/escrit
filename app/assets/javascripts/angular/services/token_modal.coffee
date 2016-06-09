@escrit.factory 'TokenModal', ['$resource', '$q', '$rootScope', ($resource, $q, $rootScope) ->
  factory = {}
  factory.capitalized = false
  factory.current_token = null
  factory.current_language_id = null

  factory.open = (token, is_capitalized, language_id) ->
    factory.current_token = token
    factory.capitalized = is_capitalized
    factory.current_language_id = language_id
    $rootScope.$broadcast('token_modal:open')

  factory.close = ->
    factory.current_token = null
    factory.current_language_id = null
    $rootScope.$broadcast('token_modal:close')

  return factory
]
