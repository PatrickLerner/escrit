function SessionsController($scope, $location, $route, Auth, $routeParams,
                            $rootScope, Modal) {
  $scope.action_name = $route.current.$$route.action_name;
  $scope.credentials = { remember_me: true };
  $scope.errors = {};

  $scope.submit = function() {
    if ($scope.action_name === 'signup') {
      Auth.register($scope.credentials, {}).then(function(user) {
        $location.url("/");
        $rootScope.$broadcast('user:set', user);
      }, function(error) { $scope.errors = error.data.errors; });
    } else if ($scope.action_name === 'signin') {
      Auth.login($scope.credentials, {}).then(function(user) {
        $location.url("/");
        $rootScope.$broadcast('user:set', user);
      }, function(error) { $scope.errors = error.data; });
    } else if ($scope.action_name === 'resetpassword') {
      let payload = $scope.credentials;
      payload.reset_password_token = $routeParams.token;
      return Auth.resetPassword(payload).then(function(user) {
        $location.url("/");
      }, error => $scope.errors = error.data.errors);
    }
  };

  $scope.resetPassword = function() {
    let payload = { email: $scope.credentials.email };
    if (!payload.email) {
      $scope.errors = { error: 'Please enter your E-Mail first.'};
      return;
    }
    Modal.addModal({
      title: 'Password reset',
      content: "To reset your password we need to confirm your email. " +
               "In few moments you will receive an e-mail with instructions " +
               `at ${payload.email}.`,
      buttons: {
        abort: 'Abort',
        confirm: ['primary', '', 'Reset Password'],
      }
    })
    .then(function(r) {
      if (r !== 'confirm') { return; }
      Auth.sendResetPasswordInstructions(payload).then(function (res) {
        Modal.addModal({
          title: 'Password reset',
          content: 'If a user with this e-mail address exist, you will ' +
                   'receive an e-mail containing instructions to reset the ' +
                   'password very shortly.',
          buttons: {
            ok: ['primary', '', 'Ok']
          }
        });
      }, error => $scope.errors = error.data.errors);
    });
  };
}


SessionsController.$inject =
  ['$scope', '$location', '$route', 'Auth', '$routeParams', '$rootScope',
   'Modal'];
escrit.controller('SessionsController', SessionsController);
