function Category(Resource) {
  return Resource({ name_object: 'category' });
}


Category.$inject = ['Resource'];
escrit.factory('Category', Category);
