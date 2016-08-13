@escrit.controller 'ComplimentController', ['$scope', '$cookies', ($scope, $cookies) ->
  showComplimentKey = 'ComplimentController_showCompliment'
  $scope.complimentVisible = false
  $scope.user = null

  $scope.showCompliment = ->
    $scope.complimentVisible && $scope.user? && $scope.user.id <= 4

  $scope.close = ->
    $scope.complimentVisible = false

  if $cookies.get(showComplimentKey) != undefined
    $scope.complimentVisible = $cookies.get(showComplimentKey) == 'true'
  else
    $scope.complimentVisible = true

  $scope.$watch 'complimentVisible', (val) ->
    $cookies.put(showComplimentKey, val)

  $scope.$on 'user:set', (event, user) ->
    $scope.user = user

  $scope.$on 'devise:logout', (event, old_user) ->
    $scope.user = null
    $scope.complimentVisible = true
]
