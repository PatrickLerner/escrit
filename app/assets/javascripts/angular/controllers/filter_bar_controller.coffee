@escrit.controller 'FilterBarController', ['$scope', ($scope) ->
  $scope.open = null

  $scope.toggle = (name) ->
    if $scope.open == name
      $scope.open = null
    else
      $scope.open = name
]
