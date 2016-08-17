function ServicesController($scope, $controller, Service, $location, Language) {
  $controller('ScaffoldController', { $scope: $scope, resource: Service });

  Language.findAll().then(collection => $scope.languages = collection);

  $scope.afterSave = object => $location.url($scope.index_path());
}


ServicesController.$inject =
  ['$scope', '$controller', 'Service', '$location', 'Language'];
escrit.controller('ServicesController', ServicesController);
