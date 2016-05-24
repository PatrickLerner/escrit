@escrit.controller 'TextsController', ($scope, $controller, Text, $routeParams,
  $location, Modal, $rootScope) ->
  $controller 'ScaffoldController',
    $scope: $scope,
    resource: Text

  $scope.showWord = (token) ->
    alert(token)
