function Text(Resource) {
  return Resource({ name_object: 'text' });
}


Text.$inject = ['Resource'];
escrit.factory('Text', Text);
