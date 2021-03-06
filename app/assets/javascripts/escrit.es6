let escrit = angular.module('escrit',
  ['ngRoute', 'ngResource', 'templates', 'Devise', 'ngAnimate', 'ngCookies']
);

escrit.run(['$rootScope', '$location', 'Auth', ($rootScope, $location, Auth) =>
  $rootScope.$on('$routeChangeStart', (event, next, current) =>
    Auth.currentUser().then(user => null,
      function(error) {
        if (next.originalPath !== '/signin' &&
            next.originalPath !== '/signup' &&
            next.originalPath !== '/resetpassword') {
          event.preventDefault();
          $rootScope.$evalAsync(() => $location.path('/signin'));
        }
      }
    )
  )
]);

escrit.config(['AuthProvider', 'AuthInterceptProvider',
  function(AuthProvider, AuthInterceptProvider) {
    AuthProvider.loginPath('/signin.json');
    AuthProvider.logoutPath('/signout.json');
    AuthProvider.registerPath('/signup.json');
    AuthProvider.sendResetPasswordInstructionsPath('/resetpassword.json');
    return AuthProvider.resetPasswordPath('/resetpassword.json');
  }
]);

escrit.config(['$routeProvider', '$locationProvider',
  function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);
    return $routeProvider
      // session
      .when('/signin', {
        templateUrl: 'sessions/signin.html',
        controller: 'SessionsController',
        action_name: 'signin'
      })
      .when('/signup', {
        templateUrl: 'sessions/signup.html',
        controller: 'SessionsController',
        action_name: 'signup'
      })
      .when('/resetpassword', {
        templateUrl: 'sessions/resetpassword.html',
        controller: 'SessionsController',
        action_name: 'resetpassword'
      })
      // services
      .when('/services', {
        templateUrl: 'services/index.html',
        controller: 'ServicesController',
        action_name: 'index'
      })
      .when('/services/new', {
        templateUrl: 'services/new.html',
        controller: 'ServicesController',
        action_name: 'new'
      })
      .when('/services/:id/edit', {
        templateUrl: 'services/edit.html',
        controller: 'ServicesController',
        action_name: 'edit'
      })
      // texts
      .when('/texts', {
        templateUrl: 'texts/index.html',
        controller: 'TextsController',
        action_name: 'index'
      })
      .when('/texts/new', {
        templateUrl: 'texts/new.html',
        controller: 'TextsController',
        action_name: 'new'
      })
      .when('/texts/:id/edit', {
        templateUrl: 'texts/edit.html',
        controller: 'TextsController',
        action_name: 'edit'
      })
      .when('/texts/:id', {
        templateUrl: 'texts/show.html',
        controller: 'TextsController',
        action_name: 'show'
      })
      // else
      .otherwise({
        redirectTo: '/texts'
      });
  }
]);
