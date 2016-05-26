@escrit.factory 'TokenModal', ($resource, $q, $rootScope) ->
  current_token = null
  factory = {}

  factory.open = (token) ->
    current_token = token
    $rootScope.$broadcast('token_modal:open')

  factory.close = ->
    current_token = null
    $rootScope.$broadcast('token_modal:close')

  factory.current_token = ->
    current_token

  return factory
