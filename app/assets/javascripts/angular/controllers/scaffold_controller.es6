function ScaffoldController($scope, resource, Modal, $location, $routeParams,
                            $route) {
  $scope.action_name = $route.current.$$route.action_name;
  $scope.errors = {};
  $scope.loading = false;
  $scope.filters = {};

  $scope.loadEdit = function() {
    $scope.loading = true;

    resource.find($routeParams.id).then(function(response) {
      $scope[resource.name_object] = response;
      $scope.loading = false;
      if (!$scope.can('update'))
        $location.url('/');
    }, function(error) {
      $location.url(`/${resource.path}`);
      $scope.loading = false;
    });
  };

  $scope.loadIndex = function(page = 1) {
    $scope.loading = true;

    resource.findAll(page, $scope.filters).then(function(collection) {
      $scope[resource.name_collection] = collection;
      $scope.loading = false;
    });
  };

  $scope.loadNew = function() {
    $scope[resource.name_object] = resource.new();
    if (!$scope.can('create'))
      $location.url('/');
  };

  $scope.loadShow = function() {
    $scope.loading = true;

    resource.find($routeParams.id).then(function(response) {
      $scope[resource.name_object] = response;
      $scope.loading = false;
      if ($scope.onLoadShow !== undefined)
        $scope.onLoadShow();
      if (!$scope.can('read'))
        $location.url('/');
    }, function(error) {
      $location.url(`/${resource.path}`);
      $scope.loading = false;
    });
  };

  $scope.showPage = page => $scope.loadIndex(page);

  $scope.submit = function() {
    resource.save($scope[resource.name_object]).then(function (response) {
      $scope.afterSave(response);
    }, function(error) {
      if (error.status >= 500)
        Modal.reportCommunicationError();
      else
        $scope.errors = error.data;
    });
  };

  $scope.delete = function(object) {
    Modal.addModal({
      title: `Delete ${resource.name_object}`,
      content: `Do you really wish to delete this ${resource.name_object}?`,
      buttons: {
        abort: 'Abort',
        confirm: ['danger', 'close', 'Delete'],
      }
    }).then(function(r) {
      if (r !== 'confirm') { return; }
      resource.destroy(object.to_param).then(function (response) {
        $location.url(`/${resource.path}/`);
      }, function(error) {
        $scope.errors = error.data;
      });
    });
  };

  $scope.can = function(action) {
    if ($scope[resource.name_object] === undefined) { return true; }
    if ($scope[resource.name_object].permissions === undefined) { return true; }
    return $scope[resource.name_object].permissions[action];
  };

  $scope.new_path = () => `/${resource.path}/new`;

  $scope.edit_path = function(object) {
    if (object === undefined) { return ''; }
    return `/${resource.path}/${object.to_param}/edit`;
  };

  $scope.show_path = function(object) {
    if (object === undefined) { return ''; }
    return `/${resource.path}/${object.to_param}`;
  };

  $scope.index_path = () => `/${resource.path}`;

  $scope.afterSave = object => $location.url($scope.show_path(object));

  switch ($scope.action_name) {
    case 'edit':  return $scope.loadEdit();
    case 'index': return $scope.loadIndex();
    case 'show':  return $scope.loadShow();
    case 'new':   return $scope.loadNew();
  }
}


ScaffoldController.$inject =
  ['$scope', 'resource', 'Modal', '$location', '$routeParams', '$route'];
escrit.controller('ScaffoldController', ScaffoldController);
