@escrit.controller 'ScaffoldController', ($scope, resource, Modal, $location,
  $routeParams, $route) ->

  $scope.action_name = $route.current.$$route.action_name
  $scope.errors = {}

  $scope.loadEdit = ->
    resource.find($routeParams.id).then (response) ->
      $scope[resource.name_object] = response
    , (error) ->
      $location.url "/#{resource.path}"

  $scope.loadIndex = (page = 1) ->
    resource.findAll(page).then (collection) ->
      $scope[resource.name_collection] = collection

  $scope.loadNew = ->
    $scope[resource.name_object] = resource.new()

  $scope.loadShow = ->
    resource.find($routeParams.id).then (response) ->
      $scope[resource.name_object] = response
    , (error) ->
      $location.url "/#{resource.path}"

  $scope.showPage = (page) ->
    $scope.loadIndex(page)

  $scope.submit = ->
    resource.save($scope[resource.name_object]).then (response) ->
      $scope.afterSave(response)
    , (error) ->
      $scope.errors = error.data

  $scope.delete = (object) ->
    Modal.addModal({
      title: "Delete #{resource.name_object}"
      content: "Do you really wish to delete this #{resource.name_object}?",
      buttons:
        abort: 'Abort'
        confirm: ['primary', 'times', 'Delete'],
    }).then (r) ->
      return unless r == 'confirm'
      resource.destroy(object.to_param).then (response) ->
        $location.url "/#{resource.path}/"
      , (error) ->
        $scope.errors = error.data

  $scope.createNew = ->
    $location.url "/#{resource.path}/new"

  $scope.edit = (object) ->
    $location.url "/#{resource.path}/#{object.to_param}/edit"

  $scope.show = (object) ->
    $location.url "/#{resource.path}/#{object.to_param}"

  $scope.showIndex = ->
    $location.url "/#{resource.path}"

  $scope.afterSave = (object) ->
    $scope.show(object)

  switch $scope.action_name
    when 'edit'  then $scope.loadEdit()
    when 'index' then $scope.loadIndex()
    when 'show'  then $scope.loadShow()
    when 'new'   then $scope.loadNew()
