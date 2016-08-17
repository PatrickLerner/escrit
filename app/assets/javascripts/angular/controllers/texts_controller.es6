function TextsController($scope, $controller, Text, $routeParams, $location,
                         Modal, $rootScope, TokenModal, Language, Audio,
                         Category) {
  $controller('ScaffoldController', { $scope: $scope, resource: Text });

  Language.findAll().then(collection => $scope.languages = collection);
  Category.findAll().then(collection => $scope.categories = collection);

  $scope.filters = {
    language_id: [], public: false, query: '', category_id: null
  };
  $scope.unknownWords = {};
  $scope.$watch('filters.query', () => $scope.loadIndex(1));

  $scope.toggleLanguageSelection = function(language_id) {
    const idx = $scope.filters.language_id.indexOf(language_id);

    if (idx > -1)
      $scope.filters.language_id.splice(idx, 1);
    else
      $scope.filters.language_id.push(language_id);

    $scope.loadIndex(1);
  };

  $scope.selectCategory = function(category_id) {
    if ($scope.filters.category_id === category_id)
      category_id = null;
    $scope.filters.category_id = category_id;
    $scope.loadIndex(1);
  };

  $scope.toggleShowPublic = function() {
    $scope.filters.public = !$scope.filters.public;
    $scope.loadIndex(1);
  };

  $scope.showWord = function(token, capitalized) {
    $scope.unknownWords[token] = true;
    TokenModal.open(token, capitalized, $scope.text.language_id);
  };

  $scope.onLoadShow = () => Audio.init();

  $rootScope.$on('token_modal:open', () => $scope.loading = true);
  $rootScope.$on('token_modal:opened', () => $scope.loading = false);
}


TextsController.$inject = ['$scope', '$controller', 'Text', '$routeParams',
                           '$location', 'Modal', '$rootScope', 'TokenModal',
                           'Language', 'Audio', 'Category'];
escrit.controller('TextsController', TextsController);
