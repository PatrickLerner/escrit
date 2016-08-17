function Token(Resource) {
  return Resource({ name_object: 'token' });
}


Token.$inject = ['Resource'];
escrit.factory('Token', Token);
