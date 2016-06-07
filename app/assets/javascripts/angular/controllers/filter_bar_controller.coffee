@escrit.controller 'FilterBarController', ['$scope', ($scope) ->
  $scope.open = {}

  $scope.toggle = (name) ->
    $scope.open[name] = !($scope.open[name] || false)
]
