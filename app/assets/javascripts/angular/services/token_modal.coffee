@escrit.factory 'TokenModal', ['$resource', '$q', '$rootScope', ($resource, $q, $rootScope) ->
  current_token = null
  current_language_id = null
  factory = {}

  factory.open = (token, language_id) ->
    current_token = token
    current_language_id = language_id
    $rootScope.$broadcast('token_modal:open')

  factory.close = ->
    current_token = null
    current_language_id = null
    $rootScope.$broadcast('token_modal:close')

  factory.current_token = ->
    current_token

  factory.current_language_id = ->
    current_language_id

  return factory
]
