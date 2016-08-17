function ModalController($scope, Modal, $rootScope) {
  $scope.modals = [];

  $scope.closeModal = val => Modal.pop(val);

  $scope.closeBackground = function($event, val) {
    if ($event.target.className !== "modal-fade-screen") { return; }
    $scope.closeModal(val);
  };

  $rootScope.$on('modal:open', () => $scope.modals = Modal.getAll());
  $rootScope.$on('modal:close', () => $scope.modals = Modal.getAll());
}


ModalController.$inject = ['$scope', 'Modal', '$rootScope'];
escrit.controller('ModalController', ModalController);
