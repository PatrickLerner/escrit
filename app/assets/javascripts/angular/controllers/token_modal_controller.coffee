@escrit.controller 'TokenModalController', ($scope, Modal, TokenModal,
  $rootScope) ->
  $scope.current_token = null

  $scope.closeModal = (val) ->
    TokenModal.close()

  $scope.closeBackground = ($event, val) ->
    return unless $event.target.className == "modal-fade-screen"
    $scope.closeModal(val)

  $rootScope.$on 'token_modal:open', ->
    $scope.current_token = TokenModal.current_token()

  $rootScope.$on 'token_modal:close', ->
    $scope.current_token = null
