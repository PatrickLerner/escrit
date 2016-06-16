@escrit.controller 'TextsController', ['$scope', '$controller', 'Text', '$routeParams', '$location', 'Modal', '$rootScope', 'TokenModal', 'Language', ($scope, $controller, Text, $routeParams, $location, Modal, $rootScope, TokenModal, Language) ->
  $controller 'ScaffoldController',
    $scope: $scope,
    resource: Text

  Language.findAll().then (collection) ->
    $scope.languages = collection

  $scope.filters = { language_id: [], public: false, query: '' }
  $scope.unknownWords = {}

  $scope.$watch 'filters.query', ->
    $scope.loadIndex(1)

  $scope.toggleLanguageSelection = (language_id) ->
    idx = $scope.filters.language_id.indexOf(language_id)

    if (idx > -1)
      $scope.filters.language_id.splice(idx, 1)
    else
      $scope.filters.language_id.push(language_id)

    $scope.loadIndex(1)

  $scope.toggleShowPublic = ->
    $scope.filters.public = !$scope.filters.public
    $scope.loadIndex(1)

  $scope.showWord = (token, capitalized) ->
    $scope.unknownWords[token] = true
    TokenModal.open(token, capitalized, $scope.text.language_id)

  $rootScope.$on 'token_modal:open', => $scope.loading = true

  $rootScope.$on 'token_modal:opened', => $scope.loading = false
]
