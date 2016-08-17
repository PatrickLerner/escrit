function Language(Resource) {
  return Resource({ name_object: 'language' });
}


Language.$inject = ['Resource'];
escrit.factory('Language', Language);
