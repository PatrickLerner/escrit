@escrit.controller 'ModalController', ($scope, Modal, $rootScope) ->
  $scope.modals = []

  $scope.closeModal = (val) ->
    Modal.pop(val)

  $scope.closeBackground = ($event, val) ->
    return unless $event.target.className == "modal-fade-screen"
    $scope.closeModal(val)

  $rootScope.$on 'modal:open', ->
    $scope.modals = Modal.getAll()

  $rootScope.$on 'modal:close', ->
    $scope.modals = Modal.getAll()
