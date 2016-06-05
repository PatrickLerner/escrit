@escrit.controller 'ScaffoldController', ['$scope', 'resource', 'Modal', '$location', '$routeParams', '$route', ($scope, resource, Modal, $location, $routeParams, $route) ->

  $scope.action_name = $route.current.$$route.action_name
  $scope.errors = {}
  $scope.loading = false
  $scope.filters = {}

  $scope.loadEdit = ->
    $scope.loading = true
    resource.find($routeParams.id).then (response) ->
      $scope[resource.name_object] = response
      $scope.loading = false
    , (error) ->
      $location.url "/#{resource.path}"
      $scope.loading = false

  $scope.loadIndex = (page = 1) ->
    $scope.loading = true
    resource.findAll(page, $scope.filters).then (collection) ->
      $scope[resource.name_collection] = collection
      $scope.loading = false

  $scope.loadNew = ->
    $scope[resource.name_object] = resource.new()

  $scope.loadShow = ->
    $scope.loading = true
    resource.find($routeParams.id).then (response) ->
      $scope[resource.name_object] = response
      $scope.loading = false
    , (error) ->
      $location.url "/#{resource.path}"
      $scope.loading = false

  $scope.showPage = (page) ->
    $scope.loadIndex(page)

  $scope.submit = ->
    resource.save($scope[resource.name_object]).then (response) ->
      $scope.afterSave(response)
    , (error) ->
      if error.status >= 500
        Modal.reportCommunicationError()
      else
        $scope.errors = error.data

  $scope.delete = (object) ->
    Modal.addModal({
      title: "Delete #{resource.name_object}"
      content: "Do you really wish to delete this #{resource.name_object}?",
      buttons:
        abort: 'Abort'
        confirm: ['danger', 'close', 'Delete'],
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
]
