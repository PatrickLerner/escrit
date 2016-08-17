function Word(Resource) {
  return Resource({ name_object: 'word' });
}


Word.$inject = ['Resource'];
escrit.factory('Word', Word);
