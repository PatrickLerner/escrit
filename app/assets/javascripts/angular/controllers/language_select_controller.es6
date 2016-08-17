function LanguageSelectController($scope, Language) {
  Language.findAll().then(collection => $scope.languages = collection);
}


LanguageSelectController.$inject = ['$scope', 'Language'];
escrit.controller('LanguageSelectController', LanguageSelectController);
