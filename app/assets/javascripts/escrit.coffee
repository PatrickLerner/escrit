@escrit = angular.module 'escrit', ['ngRoute', 'ngResource', 'templates',
  'Devise', 'ngAnimate']

@escrit.run ($rootScope, $location, Auth) ->
  $rootScope.$on '$routeChangeStart', (event, next, current) ->
    Auth.currentUser().then (user) ->
      null
    , (error) ->
      unless next.originalPath in ['/signin', '/signup', '/resetpassword']
        event.preventDefault()
        $rootScope.$evalAsync ->
          $location.path('/signin')

@escrit.config (AuthProvider, AuthInterceptProvider) ->
  AuthProvider.loginPath '/signin.json'
  AuthProvider.logoutPath '/signout.json'
  AuthProvider.registerPath '/signup.json'
  AuthProvider.sendResetPasswordInstructionsPath '/resetpassword.json'
  AuthProvider.resetPasswordPath '/resetpassword.json'

@escrit.config ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
  $routeProvider
    # session
    .when '/signin',
      templateUrl: 'sessions/signin.html',
      controller: 'SessionsController',
      action_name: 'signin'
    .when '/signup',
      templateUrl: 'sessions/signup.html',
      controller: 'SessionsController',
      action_name: 'signup'
    .when '/resetpassword',
      templateUrl: 'sessions/resetpassword.html',
      controller: 'SessionsController',
      action_name: 'resetpassword'
    # texts
    .when '/texts',
      templateUrl: 'texts/index.html',
      controller: 'TextsController',
      action_name: 'index'
    .when '/texts/new',
      templateUrl: 'texts/new.html',
      controller: 'TextsController',
      action_name: 'new'
    .when '/texts/:id/edit',
      templateUrl: 'texts/edit.html',
      controller: 'TextsController',
      action_name: 'edit'
    .when '/texts/:id',
      templateUrl: 'texts/show.html',
      controller: 'TextsController',
      action_name: 'show'
    # else
    .otherwise
      redirectTo: '/texts'
