@escrit.controller 'LanguageSelectController', ($scope, $controller, Language,
  $routeParams, $location, Modal, $rootScope) ->

  Language.findAll().then (collection) ->
    $scope.languages = collection
