function Service(Resource) {
  return Resource({ name_object: 'service', backend_path: 'services' });
}


Service.$inject = ['Resource'];
escrit.factory('Service', Service);
