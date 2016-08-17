function Resource($resource) {
  return function(obj) {
    if (!obj) { obj = {}; }
    if (!obj.name_object) { obj.name_object = 'resource'; }
    if (!obj.name_collection) { obj.name_collection = obj.name_object.pluralize(); }
    if (!obj.path) { obj.path = obj.name_collection; }
    if (!obj.backend_path) { obj.backend_path = obj.path; }
    let resource_methods = {
      query: {
        method: 'GET',
        isArray: true,
        transformResponse: function(data) {
          let r = angular.fromJson(data);
          if (Array.isArray(r)) { return r; }
          if (r.page === undefined) { return r; }
          r.data.$metadata = {
            page: parseInt(r.page),
            num_pages: parseInt(r.num_pages),
            per_page: parseInt(r.per_page)
          };
          return r.data;
        },
        interceptor: {
          response: function(res) {
            if (Array.isArray(res)) { return res; }
            res.resource.$metadata = res.data.$metadata;
            return res.resource;
          }
        }
      },
       update: {
         method: 'PUT'
       }
    };

    if (!obj.resource) { obj.resource = $resource(`/${obj.backend_path}/:id.json`, { id: '@id' }, resource_methods); }

    obj.find = id => obj.resource.get({id}).$promise;

    obj.findAll = function(page = 1, filters = {}) {
      let params = { page };
      for (let key in filters) {
        let value = filters[key];
        let key_name = `filters[${key}]`;
        if (Array.isArray(value)) {
          key_name += '[]';
        }
        params[key_name] = value;
      }
      return obj.resource.query(params).$promise;
    };

    obj.new = () => new obj.resource();

    obj.save = function(data) {
      let payload = {};
      payload[obj.name_object] = data;
      if (data.to_param !== undefined) {
        payload.id = data.to_param;
        return obj.resource.update(payload).$promise;
      } else {
        return obj.resource.save(payload).$promise;
      }
    };

    obj.destroy = id => obj.resource.remove({ id }).$promise;

    return obj;
  };
}

Resource.$inject = ['$resource'];
escrit.factory('Resource', Resource);
