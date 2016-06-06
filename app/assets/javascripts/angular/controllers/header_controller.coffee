@escrit.controller 'HeaderController', ['$scope', '$location', '$route', 'Auth', '$routeParams', '$rootScope', ($scope, $location, $route, Auth, $routeParams, $rootScope) ->
  $scope.largeHeader = true
  $scope.showMenu = false
  $scope.user = null
  $scope.noScroll = false

  $scope.toggleHeader = () ->
    $scope.largeHeader = !$scope.largeHeader

  $scope.toggleMenu = () ->
    $scope.showMenu = !$scope.showMenu
    $scope.noScroll = $scope.showMenu

  $scope.signOut = () ->
    Auth.logout({}).then (oldUser) ->
      $location.url '/'

  $scope.signIn = () ->
    $location.url '/signin'

  $scope.signUp = () ->
    $location.url '/signup'

  $rootScope.$on 'modal:open', (event) ->
    $scope.noScroll = true

  $rootScope.$on 'modal:close', (event) ->
    $scope.noScroll = false

  $rootScope.$on 'token_modal:open', (event) ->
    $scope.noScroll = true

  $rootScope.$on 'token_modal:close', (event) ->
    $scope.noScroll = false

  $scope.$on 'user:set', (event, user) ->
    $scope.user = user

  $scope.$on 'devise:login', (event, currentUser) ->
    $rootScope.$broadcast('user:set', currentUser)

  $scope.$on 'devise:new-session', (event, currentUser) ->
    $rootScope.$broadcast('user:set', currentUser)

  $scope.$on 'devise:logout', (event, oldCurrentUser) ->
    $rootScope.$broadcast('user:set', null)
]
