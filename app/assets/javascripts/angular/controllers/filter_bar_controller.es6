function FilterBarController($scope) {
  $scope.open = null;

  $scope.toggle = function(name) {
    if ($scope.open === name)
      $scope.open = null;
    else
      $scope.open = name;
  };
}

FilterBarController.$inject = ['$scope'];
escrit.controller('FilterBarController', FilterBarController);
