@escrit.factory 'Modal', ['$resource', '$q', '$rootScope', ($resource, $q, $rootScope) ->
  modal_list = []
  factory = {}

  factory.push = (data) ->
    for val, text of data.buttons
      data.buttons[val] = if Array.isArray(text)
        text
      else
        [null, null, text]
    modal_list.push(data)
    $rootScope.$broadcast('modal:open')

  factory.pop = (val) ->
    modal = modal_list.pop()
    modal.promise.resolve(val)
    $rootScope.$broadcast('modal:close')

  factory.addModal = (data) ->
    defer = $q.defer()
    data['promise'] = defer
    factory.push(data)
    return defer.promise

  factory.reportCommunicationError = ->
    factory.addModal
      title: "Error communicating with server"
      content: "It looks like there was a problem connecting and " +
               "communicating with the server. You might try again later " +
               "or get in contact with the administration of the site to " +
               "resolve the problem. Sorry for the inconvenience.",
      buttons:
        confirm: ['danger', 'close', 'Close']

  factory.getAll = () ->
    modal_list

  return factory
]
