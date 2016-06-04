@escrit.controller 'TextsController', ['$scope', '$controller', 'Text', '$routeParams', '$location', 'Modal', '$rootScope', 'TokenModal', ($scope, $controller, Text, $routeParams, $location, Modal, $rootScope, TokenModal) ->
  $controller 'ScaffoldController',
    $scope: $scope,
    resource: Text

  $scope.showWord = (token) ->
    TokenModal.open(token, $scope.text.language_id)
]
