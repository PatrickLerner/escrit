@escrit.factory 'Resource', ['$resource', ($resource) ->
  return (obj) ->
    obj ||= {}
    obj.name_object ||= 'resource'
    obj.name_collection ||= obj.name_object.pluralize()
    obj.path ||= obj.name_collection
    obj.backend_path ||= obj.path
    resource_methods =
      query:
        method: 'GET'
        isArray: true
        transformResponse: (data) ->
          r = angular.fromJson(data)
          return r if Array.isArray(r)
          return r unless r.page?
          r.data.$metadata =
            page: parseInt(r.page)
            num_pages: parseInt(r.num_pages)
            per_page: parseInt(r.per_page)
          return r.data
        interceptor:
          response: (res) ->
            return res if Array.isArray(res)
            res.resource.$metadata = res.data.$metadata
            return res.resource
       update:
         method: 'PUT'

    obj.resource ||= $resource "/#{obj.backend_path}/:id.json",
                               { id: '@id' }
                               resource_methods

    obj.find = (id) ->
      obj.resource.get({id: id}).$promise

    obj.findAll = (page = 1, filters = {}) ->
      params = { page: page }
      for key, value of filters
        params["filters[#{key}]"] = value
      obj.resource.query(params).$promise

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
]
