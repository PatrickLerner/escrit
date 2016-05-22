@escrit.controller 'SessionsController', ($scope, $location, $route, Auth,
  $routeParams, $rootScope) ->
  $scope.action_name = $route.current.$$route.action_name
  $scope.credentials = {}
  $scope.errors = {}

  $scope.signin = () ->
    $location.url "/signin"

  $scope.signup = () ->
    $location.url "/signup"

  $scope.submit = () ->
    if $scope.action_name == 'signup'
      Auth.register($scope.credentials, {}).then (user) ->
        $location.url "/"
        $rootScope.$broadcast('user:set', user)
      , (error) ->
        $scope.errors = error.data.errors
    else if $scope.action_name == 'signin'
      Auth.login($scope.credentials, {}).then (user) ->
        $location.url "/"
        $rootScope.$broadcast('user:set', user)
      , (error) ->
        $scope.errors = error.data
