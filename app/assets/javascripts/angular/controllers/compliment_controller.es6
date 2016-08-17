function ComplimentController($scope, $cookies) {
  const showComplimentKey = 'ComplimentController_showCompliment';
  $scope.complimentVisible = false;
  $scope.user = null;

  $scope.showCompliment = () =>
    $scope.complimentVisible && ($scope.user !== null) && ($scope.user.id <= 4);

  $scope.close = () => $scope.complimentVisible = false;

  if ($cookies.get(showComplimentKey) !== undefined) {
    $scope.complimentVisible = $cookies.get(showComplimentKey) === 'true';
  } else {
    $scope.complimentVisible = true;
  }

  $scope.$watch('complimentVisible', v => $cookies.put(showComplimentKey, v));

  $scope.$on('user:set', (event, user) => $scope.user = user);

  $scope.$on('devise:logout', function(event, old_user) {
    $scope.user = null;
    $scope.complimentVisible = true;
  });
}

ComplimentController.$inject = ['$scope', '$cookies'];
escrit.controller('ComplimentController', ComplimentController);
