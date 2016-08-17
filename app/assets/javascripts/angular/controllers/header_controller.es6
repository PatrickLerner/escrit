function HeaderController($scope, $location, Auth, $rootScope) {
  $scope.largeHeader = false;
  $scope.showMenu = false;
  $scope.user = null;
  $scope.noScroll = false;

  $scope.toggleHeader = () => $scope.largeHeader = !$scope.largeHeader;

  $scope.toggleMenu = function() {
    $scope.showMenu = !$scope.showMenu;
    $scope.noScroll = $scope.showMenu;
  };

  $scope.signOut = () =>
    Auth.logout({}).then(oldUser => $location.url('/'));

  $rootScope.$on('modal:open', event => $scope.noScroll = true);
  $rootScope.$on('modal:close', event => $scope.noScroll = false);
  $rootScope.$on('token_modal:open', event => $scope.noScroll = true);
  $rootScope.$on('token_modal:close', event => $scope.noScroll = false);
  $scope.$on('user:set', (event, user) => $scope.user = user);

  $scope.$on('devise:login', function(event, currentUser) {
    $rootScope.$broadcast('user:set', currentUser);
  });

  $scope.$on('devise:new-session', function(event, currentUser) {
    $rootScope.$broadcast('user:set', currentUser);
  });

  $scope.$on('devise:logout', function(event, oldCurrentUser) {
    $rootScope.$broadcast('user:set', null);
  });
}


HeaderController.$inject = ['$scope', '$location', 'Auth', '$rootScope'];
escrit.controller('HeaderController', HeaderController);
