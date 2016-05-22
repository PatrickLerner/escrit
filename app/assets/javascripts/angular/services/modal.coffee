@escrit.factory 'Modal', ($resource, $q, $rootScope) ->
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

  factory.getAll = () ->
    modal_list

  return factory
