@escrit.controller 'ServicesController', ['$scope', '$controller', 'Service', '$routeParams', '$location', 'Modal', '$rootScope', 'Language', ($scope, $controller, Service, $routeParams, $location, Modal, $rootScope, Language) ->
  $controller 'ScaffoldController',
    $scope: $scope,
    resource: Service

  Language.findAll().then (collection) ->
    $scope.languages = collection

  $scope.afterSave = (object) ->
    $location.url $scope.index_path()
]
