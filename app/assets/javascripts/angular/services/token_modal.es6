 function TokenModal($resource, $q, $rootScope) {
  let factory = {};
  factory.capitalized = false;
  factory.current_token = null;
  factory.current_language_id = null;

  factory.open = function(token, is_capitalized, language_id) {
    factory.current_token = token;
    factory.capitalized = is_capitalized;
    factory.current_language_id = language_id;
    $rootScope.$broadcast('token_modal:open');
  };

  factory.close = function() {
    factory.current_token = null;
    factory.current_language_id = null;
    $rootScope.$broadcast('token_modal:close');
  };

  return factory;
}


TokenModal.$inject = ['$resource', '$q', '$rootScope'];
escrit.factory('TokenModal', TokenModal);
