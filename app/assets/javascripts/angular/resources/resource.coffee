@escrit.factory 'Resource', ($resource) ->
  return (obj) ->
    obj ||= {}
    obj.name_object ||= 'resource'
    obj.name_collection ||= obj.name_object.pluralize()
    obj.path ||= obj.name_collection
    obj.backend_path ||= obj.path
    obj.resource ||= $resource "/#{obj.backend_path}/:id.json",
                               { id: '@id' },
                               { 'update': { method: 'PUT' } }

    obj.find = (id) ->
      obj.resource.get({id: id}).$promise

    obj.findAll = (id) ->
      obj.resource.query().$promise

    obj.new = () ->
      new obj.resource()

    obj.save = (data) ->
      payload = {}
      payload[obj.name_object] = data
      if data.to_param?
        payload['id'] = data.to_param
        obj.resource.update(payload).$promise
      else
        obj.resource.save(payload).$promise

    obj.destroy = (id) ->
      obj.resource.remove({ id: id }).$promise

    return obj
